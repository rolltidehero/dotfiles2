# Android Dotfiles

Command to setup Termux with git and clone a repository to the Android device. Used for accessing obsidian vault on device

```bash
curl -fsSL curl -fsSL https://raw.githubusercontent.com/davzoku/dotfiles/master/android/termux/setup_termux | bash -s -- <repository-url>
```

Setup colors on Termux

```bash
curl -o ~/.termux/colors.properties https://raw.githubusercontent.com/davzoku/dotfiles/master/termux/colors.properties && termux-reload-settings
```
