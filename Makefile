all:
	@printf "Targets:\n\tswitch\n\tupdate-git\n"
switch: 
	sudo nixos-rebuild switch -I nixpkgs=/etc/nixos/nixpkgs
upgrade: update-nixpkgs
	sudo nixos-rebuild switch -I nixpkgs=/etc/nixos/nixpkgs
update-nixpkgs: nixpkgs update-channel
	cd nixpkgs; \
	git fetch upstream; \
	git checkout upstream-nixos-channel; \
	git merge $(shell curl -sI http://nixos.org/channels/nixos-14.04/ | grep Location | sed -e s:.\*\\.::g -e s:/::g); \
	git checkout nixos-channel; \
	git rebase upstream-nixos-channel
update-channel:
	sudo nix-channel --update nixos
