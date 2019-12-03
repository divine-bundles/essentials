* [**`improvement`**] Make the `home-dirs` deployment use the stashing system to track previous installations/removals.
* [**`improvement`**] Remove full ref decoration from the alias for the `git log` command.
* [**`improvement`**] On macOS:
  * Do not install Zsh, as it is usually pre-loaded.
  * Silence the warnings about the deprecation of Bash as the macOS's default shell. These otherwise appear on Catalina and onward.