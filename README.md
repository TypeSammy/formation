# 🐝 Formation

![Let's get in formation](assets/formation.gif)

> Shell scripts that set up a Mac for development: apps, CLI tools, dotfiles, Claude Code preferences and macOS settings.

Safe to run more than once. Anything already installed is skipped, and existing dotfiles are only replaced if you say yes.

## Before you start

-   Sign in to the App Store, so App Store apps can install.
-   Have your Mac password ready. The script asks for it once.
-   It asks a few questions along the way:
    -   Create an SSH key (if you don't have one) and add it to GitHub
    -   Install Cursor and Xcode (both default to no)
    -   Run the customisations ("hot sauce")
    -   Replace any existing dotfiles or editor settings that differ from formation's (default no; old ones are kept as `.bak`)

## Install

1.  Install Apple's command line tools, which include git:

    ```sh
    xcode-select --install
    ```

2.  Clone formation. Clone it rather than downloading a zip, because `~/.claude/CLAUDE.md` is linked into this folder and you'll want to commit changes to it:

    ```sh
    git clone -b sam-updates https://github.com/TypeSammy/formation.git ~/code/personal/formation
    cd ~/code/personal/formation
    ```

3.  Read what it does (please don't run scripts you don't understand), then run it:

    ```sh
    less slay
    ./slay 2>&1 | tee ~/slay.log
    ```

    The output is saved to `~/slay.log`.

## After it finishes

1.  Quit and reopen your terminal.
2.  If the script copied your SSH key, paste it into [GitHub](https://github.com/settings/keys).
3.  In iTerm2, go to **Settings → Profiles**, select **Almost Dracula** and click **Other Actions → Set as Default**.
4.  Open and sign in to your apps (Claude, Slack, Docker Desktop and so on).

To pick up changes later, `git pull` and run `./slay` again.

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
-   [tmux](https://github.com/tmux/tmux) terminal multiplexer
-   [zsh-completions](https://github.com/zsh-users/zsh-completions) and [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)
</details>

<details>
<summary>Apps (<a href="swag/casks"><code>swag/casks</code></a>, <a href="swag/apps"><code>swag/apps</code></a>)</summary>

-   [iTerm2](https://iterm2.com/) terminal
-   [Claude](https://claude.ai/download) desktop app and [Claude Code](https://claude.com/claude-code)
-   [Agent Deck](https://github.com/asheshgoplani/agent-deck) for managing AI coding sessions in tmux
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
-   Claude Code skills listed in [`swag/skills`](swag/skills) (Matt Pocock's `teach`, `research`, `wait-what`, `grill-me`, `grill-with-docs` and `handoff`, plus `grilling` and `domain-modeling`, which the grill skills use), installed into `~/.claude/skills` with the [skills](https://github.com/vercel-labs/skills) CLI
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

## Known issues

Apps you installed without Homebrew (for example Chrome from google.com) can't be managed by it. The script warns and skips them, and the rest of the setup carries on.

## Acknowledgements

Formation was created by [Mina Markham](https://github.com/minamarkham/formation). Inspiration and code were also taken from:

-   [Mathias Bynens'](https://github.com/mathiasbynens) [dotfiles](https://github.com/mathiasbynens/dotfiles)
-   thoughtbot's [laptop](https://github.com/thoughtbot/laptop/)

## 📜 License

Formation is customized for my own needs. It is free software, and may be redistributed under the terms specified in the [LICENSE] file.

[license]: LICENSE
