#:title:        Divine deployment: brewfile
#:author:       Grove Pyree
#:email:        grayarea@protonmail.ch
#:revdate:      2019.11.14
#:revremark:    Systematize the rest of the readmes
#:created_at:   2019.06.30

D_DPL_NAME='brewfile'
D_DPL_DESC='Taps, bottles, and casks from Brewfile (no upgrades)'
D_DPL_PRIORITY=3000
D_DPL_FLAGS=!
D_DPL_WARNING=

D_BFILE="$D__DPL_ASSET_DIR/Brewfile"

d_dpl_check()
{
  # Cut-off checks
  if ! [ "$D__OS_PKGMGR" = brew ]; then
    d__notify -! -- 'Brewfile is only relevant for macOS Homebrew'; return 3
  elif ! [ -r "$D_BFILE" -a -f "$D_BFILE" ]; then
    d__notify -l! -- "Not a readable file: $D_BFILE"; return 3
  fi

  # Additional warnings & prompts
  case $D__REQ_ROUTINE in
    check)    d__prompt -- 'Checking Brewfile is not very reliable' \
                || return 3;;
    remove)   D_ADDST_PROMPT=true
              D_ADDST_WARNING+=('Uninstalling Brewfile is dangerous');;
    *)        :;;
  esac

  # brew bundle requires Brewfile to be in current directory
  if ! pushd -- "$D__DPL_ASSET_DIR" &>/dev/null; then
    d__notify -lx -- "Failed to access asset directory: $D__DPL_ASSET_DIR"
    return 1
  fi

  ## Non-zero exit code of brew bundle check does not translate exactly to 
  #. 'Not installed.' It is rather 'Not fully installed or not up to date, or 
  #. maybe not installed at all, or maybe I just don't know.'
  local rtc; brew bundle check --verbose; rtc=$?
  popd &>/dev/null; (($rtc)) && return 0 || return 1
}

d_dpl_install()
{
  # brew bundle requires Brewfile to be in current directory
  if ! pushd -- "$D__DPL_ASSET_DIR" &>/dev/null; then
    d__notify -lx -- "Failed to access asset directory: $D__DPL_ASSET_DIR"
    return 1
  fi

  # Launch the routine; store code; return
  local rtc; brew bundle install --verbose --no-upgrade; rtc=$?
  popd &>/dev/null; (($rtc)) && return 1 || return 0
}

d_dpl_remove()
{
  ## Homebrew's bundler does not provide removal mechanism. Below code simply 
  #. reads Brewfile in reverse order and calls uninstall commands. This really 
  #. is a nuclear option, so additional user prompt is in place.
  #
  ## If any uninstallation reports failure, Divine intervention is halted 
  #. immediately, to give user chance to react.

  # Prompt user (yes, again)
  if ! d__prompt -xp 'Slash & burn?' -- \
    'This will call uninstall/untap command on every valid entry in Brewfile' \
    -n- '(File will be read in reverse order)'
  then dprint_debug 'Declined to uninstall Brewfile entries'; return 2; fi

  # Init storage variables; read Brewfile into an array
  local lar=() lbf ii etp enm etm algd=true
  while read -r lbf || [[ -n "$lbf" ]]; do lar+=("$lbf"); done < "$D_BFILE"

  # Iterate over Brewfile lines in reverse order, skipping comments
  for ((ii=${#lar[@]}-1;ii>=0;--ii)); do lbf="${lar[$ii]}"
    [[ $lbf = \#* ]] && continue
    # Extract first two words of the line; trim quotes from name
    read -r etp enm etm <<<"$lbf"; IFS=',' read -r enm etm <<<"$enm"
    [[ $enm = \'*\' || $enm = \"*\" ]] && read -r enm <<<"${enm:1:${#enm}-2}"
    # Perform action based on line type
    [ -n "$enm" ] || continue; case $etp in
      tap)  brew untap "$enm";;
      cask) brew cask uninstall "$enm";;
      brew) brew uninstall "$enm";;
      *)    continue;;
    esac; if (($?)); then algd=false; $D__OPT_FORCE || break; fi
  # Done iterating over Brewfile lines in reverse order, skipping comments
  done

  # Report and return
  if $algd; then return 0
  elif $D__OPT_FORCE; then
    d__notify -lx -- 'At least one uninstallation failed'; return 1
  else
    d__notify -lx -- 'Latest uninstallation failed;' \
      'further uninstallations were halted just in case'
    d__notify -l! -- 'Re-try with --force to ignore failures'
    return 1
  fi
}