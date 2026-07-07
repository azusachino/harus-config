{config, ...}: {
  sops = {
    # Default sops file location
    defaultSopsFile = ../../secrets/secrets.yaml;

    # Path to the age key for decryption
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";

    # Secrets to be linked into the user's home directory
    # Example:
    # secrets.notion_api_key = {
    #   path = "%r/notion_api_key";
    # };
  };
}
