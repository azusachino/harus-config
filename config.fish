# customize path (local, rust, go)
fish_add_path $HOME/.local/bin $HOME/.cargo/bin/ $HOME/go/bin/

## fish settings
### disable greeting
set fish_greeting

# setup fish with homebrew
if test -d /home/linuxbrew/.linuxbrew # Linux
	set -gx HOMEBREW_PREFIX "/home/linuxbrew/.linuxbrew"
	set -gx HOMEBREW_CELLAR "$HOMEBREW_PREFIX/Cellar"
	set -gx HOMEBREW_REPOSITORY "$HOMEBREW_PREFIX/Homebrew"
else if test -d /opt/homebrew # MacOS
	set -gx HOMEBREW_PREFIX "/opt/homebrew"
	set -gx HOMEBREW_CELLAR "$HOMEBREW_PREFIX/Cellar"
	set -gx HOMEBREW_REPOSITORY "$HOMEBREW_PREFIX/homebrew"
end

fish_add_path -gP "$HOMEBREW_PREFIX/bin" "$HOMEBREW_PREFIX/sbin"

## alias
# shortcuts & alias
alias mci="mvn clean install -Dmaven.test.skip=true"
alias mcd="mvn clean deploy -DskipTests"

alias kl="kubectl logs -f --tail 200 "
alias ss="ssh -o StrictHostKeyChecking=no "

alias sk="sudo k3s kubectl "

## functions
#
function dotenv
    for line in (cat $argv[1])
        set line (string trim $line)
        if test -z $line
        or string match -q "#*" $line
            continue
        end
        set name_value (string split -m 1 = $line)
        set name (string trim $name_value[1])
        set value (string trim $name_value[2])
        #echo "[line=$line,name_value=$name_value,name=$name,value=$value]"
        if string match -q '"*"' $value
        or string match -q "'*'" $value
            set value (string sub -s 2 -e -1 $value)
        end
        if string match -qr '[$][{][A-Za-z_][A-Za-z_0-9]*[}]' $sub1
            set sub1 (string replace '[$][{]([A-Za-z_][A-Za-z_0-9]*)[}]' '$$$1' $sub1)
        else
            set sub1 $value
        end
        if string match -qr '[$][A-Za-z_][A-Za-z_0-9]*' $sub1
            set sub2 (eval "echo $value")
        else
            set sub2 $value
        end
        #echo "[name=$name,value=$value,sub1=$sub1,sub2=$sub2]"
        set -gx $name $sub2
    end
end