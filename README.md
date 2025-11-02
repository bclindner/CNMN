# CNMN

CNMN is a simple Discord bot written in Elixir as a learning exercise.

Currently, CNMN supports:
* Music via `yt-dlp`
    * This is very flaky due to changes to YouTube's API
* Content-aware scaling of images w/ ImageMagick

## Installation/Usage

### Running the bot directly

CNMN is a relatively standard Elixir app. You'll need the following installed
before you can run it, most of this should be easy to install via a package
manager (`apt`, `dnf`, etc.):

* Elixir itself
* yt-dlp (you can use `pip install yt-dlp`)
* ff-mpeg
* Imagemagick

The bot also relies on a Discord token passed in as an environment variable;
you'll need to use [Discord's developer
portal](https://discord.com/developers/) to set up a bot identity and get a
token. Once you've done that, set the `BOT_TOKEN` environment variable to the
token it provides.

You can also set the prefix with your commands with the `BOT_PREFIX` env. The
default is `c-`.

Once you have those installed, `iex -S mix` starts the bot.

### Nix/NixOS

If you're using Nix or NixOS, you can use `nix-shell` in this directory to open
a shell with the above dependencies to skip a step.

## Using the bot

Use `c-help` to see commands. (Or, if you set BOT_PREFIX, replace `c-` with
whatever prefix you provided) You should be able to easily explore what's
possible in the bot from there.
