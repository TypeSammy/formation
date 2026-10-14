# 🐝 Formation <a href="https://www.patreon.com/minamarkham"><img src="https://c5.patreon.com/external/logo/become_a_patron_button@2x.png" width="100"></a>

![Let's get in formation](assets/formation.gif)

> Formation is a shell script to set up a macOS laptop for design and development.

It can be run multiple times on the same machine safely. It installs, upgrades, or skips packages based on what is already installed on the machine.

## Install

Download the script:

```sh
mkdir -p /Users/$(whoami)/code/personal/dotfiles

cd /Users/$(whoami)/code/personal/dotfiles

curl -L https://github.com/TypeSammy/formation/tarball/sam-updates | tar -xzv --strip-components 1 &> /dev/null;

```

Review the script (please don't run scripts you don't understand):

```sh
less slay
```

Slay:

```sh
./slay 2>&1 | tee ~/slay.log
```

Just follow the prompts and you’ll be fine. 👌

:warning: Warning: I advise against running [this script](slay) unless you understand what it’s doing to your computer.

I created this based on my own preferences; your mileage may vary.

Once the script is done, quit and relaunch Terminal.

It is highly recommended to run the script regularly to keep your computer up to date.

Your last Formation run will be saved to `~/slay.log`. To review it, run `less ~/slay.log`.

That's it! :sparkles:

## What it sets up

<details>
<summary>Basics</summary>

-   [Homebrew](https://brew.sh/) for installing everything else
-   [Oh My Zsh](https://ohmyz.sh/) with the `git` and `z` plugins (`z name-of-repo` jumps to any folder you've visited)
-   [NVM](https://github.com/nvm-sh/nvm) and the latest [Node.js](https://nodejs.org/)
-   An ed25519 SSH key, copied to your clipboard for [GitHub](https://github.com/settings/keys)
</details>

<details>
<summary>CLI tools (<a href="swag/brews"><code>swag/brews</code></a>)</summary>

-   [git](https://git-scm.com/) and [git-delta](https://github.com/dandavison/delta) for nicer diffs
-   [gh](https://cli.github.com/) GitHub CLI
-   [jq](https://jqlang.org/) for reading and filtering JSON
-   [direnv](https://direnv.net/) for per-directory `.envrc` files
-   [shellcheck](https://www.shellcheck.net/) for linting shell scripts
-   [fzf](https://github.com/junegunn/fzf) fuzzy finder
-   [mas](https://github.com/mas-cli/mas) Mac App Store CLI
-   [wget](https://www.gnu.org/software/wget/)
-   [zsh-completions](https://github.com/zsh-users/zsh-completions) and [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)
</details>

<details>
<summary>Apps (<a href="swag/casks"><code>swag/casks</code></a>, <a href="swag/apps"><code>swag/apps</code></a>)</summary>

-   [iTerm2](https://iterm2.com/) terminal
-   [Claude](https://claude.ai/download) desktop app and [Claude Code](https://claude.com/claude-code)
-   [Docker Desktop](https://www.docker.com/products/docker-desktop/)
-   [Proxyman](https://proxyman.io/) for inspecting HTTP traffic
-   [Alfred](https://www.alfredapp.com/) launcher
-   [Rectangle](https://rectangleapp.com/) window management
-   [Slack](https://slack.com/)
-   [Google Chrome](https://www.google.com/chrome/)
-   [Firefox](https://www.mozilla.org/firefox/)
-   [Spotify](https://www.spotify.com/)
-   [VLC](https://www.videolan.org/)
-   [The Unarchiver](https://theunarchiver.com/) (App Store)
-   [Xcode](https://developer.apple.com/xcode/) (App Store, optional): you'll be asked, as it's ~15 GB
</details>

<details>
<summary>Customisations (<a href="customisations"><code>customisations</code></a>)</summary>

-   `.zshrc`, `.aliases` and `.gitconfig`. If you already have a different one, you'll be asked before it's replaced, and the old one is kept as `.bak`
-   `claude/CLAUDE.md`, symlinked to `~/.claude/CLAUDE.md` so Claude Code uses the same preferences everywhere. Edits made on the machine land back in this repo
-   `claude/settings.json` (theme and status line) and `claude/statusline-script.sh`, copied into `~/.claude/`. These are copied rather than linked because Claude Code writes to its settings file
-   Cursor settings and keybindings, if Cursor is installed (you'll be asked whether to install it)
-   iTerm2 profiles and color schemes
-   VS Code settings and keybindings, if VS Code is installed
-   A global `.gitignore_global` (`.DS_Store`, `.envrc`, swap files)
-   macOS defaults (`customisations/macos`): Dock, trackpad, key repeat, Finder, screenshots to `~/Desktop/screenshots`
</details>

Adjust the files in [`swag`](swag) to change what gets installed.

## 🌶 Hot sauce

![I got hot sauce in my bag](assets/hot-sauce.gif)

[`customisations/.hot-sauce`](customisations/.hot-sauce) runs at the end of the script, after a prompt. It creates folders, copies the dotfiles, links Claude preferences and applies the macOS defaults. Put any other personal setup there.

Write customisations so they can be run safely more than once. Formation functions such as `step`, `ask` and `mkd` (from [`twirl`](twirl)) can be used in it.

## Known Issues

Cask does not recognize applications installed outside of Homebrew Cask – in the case that the script fails, you can either remove the application from the install list or uninstall the application causing the failure and try again.

## Acknowledgements

Inspiration and code was taken from many sources, including:

-   [Mathias Bynens'](https://github.com/mathiasbynens) [dotfiles](https://github.com/mathiasbynens/dotfiles)
-   thoughtbot's [laptop](https://github.com/thoughtbot/laptop/)

## 📜 License

Formation is customized for my own needs. It is free software, and may be redistributed under the terms specified in the [LICENSE] file.

[license]: LICENSE
