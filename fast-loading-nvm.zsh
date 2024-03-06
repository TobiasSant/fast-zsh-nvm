#!/bin/zsh
export NVM_DIR="$HOME/.nvm"
function load_nvm() {
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" --no-use
    [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"

    if [ ! -z "$AUTO_LOAD_NVMRC_FILES" ] && [ "$AUTO_LOAD_NVMRC_FILES" = true ]
    then
        autoload -U add-zsh-hook
        load-nvmrc() {
            if [[ -f .nvmrc && -r .nvmrc ]]; then
                nvm use
            elif [[ -f ./package.json && -r ./package.json ]]; then
                local available_versions=$(node -pe "const pkg = require('./package.json'); const nodeVersions = pkg.engines && pkg.engines.node ? pkg.engines.node.split(' || ') : null; console.log(nodeVersions ? nodeVersions.join('\n') : 'undefined')" | grep -v 'undefined')
                local installed_versions=$(nvm list node | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+' | cut -d '.' -f 1)
                local highest_version=$(comm -12 <(echo "$available_versions" | sort -V) <(echo "$installed_versions" | sort -V) | tail -n 1)
                echo "Available versions: $(echo $available_versions | tr '\n' ' ')"
                nvm use $highest_version
            elif [[ $(nvm version) != $(nvm version default) ]]; then
                echo "Reverting to nvm default version"
                nvm use default
            fi
        }
        add-zsh-hook chpwd load-nvmrc
    fi

    if [ ! -z "$LOAD_NVMRC_ON_INIT" ] && [ "$LOAD_NVMRC_ON_INIT" = true ]
    then
        load-nvmrc
    fi
}

# Initialize a new worker
async_start_worker nvm_worker -n
async_register_callback nvm_worker load_nvm
async_job nvm_worker sleep 0.1