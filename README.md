# harus-config

harus-config with various configuration files.

## services

- caddy server
- glance
- fish

## quick access

```bash
curl -o ~/.tmux.conf https://raw.githubusercontent.com/azusachino/harus-config/main/tmux.conf

curl -o ~/.config/fish/config.fish https://raw.githubusercontent.com/azusachino/harus-config/main/config.fish
```

## location

fail2ban

```bash
sudo cp /etc/fail2ban/fail2ban.conf /etc/fail2ban/fail2ban.local
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
```

## references

- https://github.com/glanceapp/glance/blob/main/docs/configuration.md
