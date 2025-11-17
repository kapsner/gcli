# gcli

To set up [gemini-cli](https://github.com/google-gemini/gemini-cli) in a containerized "sandboxed" environment, with connection to several mcp servers.

## Getting started

(This is tested only for linux systems using docker).

At first, please adjust the `DEVDIR` environment variable in the `.env` file to mount a directory of your choice from your host system into the container under `/home/node/development/` to allow the sandboxed gemini-cli access to your local paths and files on which you like to work on.
When running for the first time, run the `start.sh` script with the `--init` flag:

```bash
./start.sh --init
```

This script is going to setup a `./gemini_config/` folder including a `tmp/`-folder, a `settings.json`-file and a `user_id`-file. The config-folder being mounted into the sandboxed gemini-container.
The script also builds the `gemini_cli` docker container, which includes an ssh-server (running on container port `2375`, which is mapped to the host's port `2399` by default).

Now add a new entry to your host's `~/.ssh/config`:

```bash
Host gemini
    HostName localhost
    User node
    Port 2399
```

Once, the `start.sh` script has finished, you can create an SSH-connection into the container.
For the first launch of gemini-cli, run:

```bash
gemini --debug
```

This starts gemini-cli in debug-mode, which prints out the URL which is necessary to complete the authentication process. Copy the authentication-URL to your browser and complete the authentication process. This will generate the file `oauth_creds.json` inside the config-folder.

After having run the setup once, you can start the container using

```bash
./start.sh
```

Once started, a bash-shell will be opened inside the container at the `/home/node/development/`-directory and you can change to a specific directory of your choice where you can launch gemini-cli using the command `gemini`.


### Gemini CLI Companion (currently not working)

When using [VSCode](https://github.com/microsoft/vscode) or [Positron](https://github.com/posit-dev/positron) IDE, you can use the ['Gemini CLI Companion' Extension](https://open-vsx.org/vscode/item?itemName=Google.gemini-cli-vscode-ide-companion), which is installed by default inside the container.
To do so, run `echo $GEMINI_CLI_IDE_SERVER_PORT` inside the container and forward the port to enable the extension to communicate with `gemini-cli`, which is running inside the container ([details](https://github.com/google-gemini/gemini-cli/issues/6297#issuecomment-3212338397)).

Related issues:
- https://github.com/google-gemini/gemini-cli/issues/6297#issuecomment-3212338397
- https://github.com/google-gemini/gemini-cli/issues/7426
- https://github.com/google-gemini/gemini-cli/issues/6480
- https://github.com/google-gemini/gemini-cli/issues/6928

## Model Context Protocol Servers

This setup comes with some pre-defined MCP-servers in gemini's `settings.json` giving access to publicly available git-repositories using the [idosal/git-mcp](https://github.com/idosal/git-mcp) GitMCP server.


# Resources

- gemini-cli system prompt:
    - [current system prompt (11.11.2025)](https://github.com/google-gemini/gemini-cli/blob/2e2b066713e85a44754ad999a9d7aa1735fe3205/packages/core/src/core/prompts.ts#L122)
    - [original system prompt (17.4.2025)](https://github.com/google-gemini/gemini-cli/blob/add233c5043264d47ecc6d3339a383f41a241ae8/packages/cli/src/core/prompts.ts#L7)


# Notes

- Previously, the initial container was started in network-mode `"host"` to allow the redirect of the completed authentication process (see [here](https://github.com/google-gemini/gemini-cli/issues/1696#issuecomment-3006805819) and [here]() for further details). However, this leads to issues when running docker in rootless-mode, which is why the setup now relys on the SSH-connection.
