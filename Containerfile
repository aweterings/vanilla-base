ARG FEDORA_MAJOR_VERSION=39

## FROM quay.io/fedora/fedora-silverblue:${FEDORA_MAJOR_VERSION}
FROM quay.io/fedora-ostree-desktops/silverblue:${FEDORA_MAJOR_VERSION}

COPY rootfs/ /
COPY cosign.pub /etc/pki/containers/

RUN <<-EOT bash
	set -eu

	systemctl enable dconf-update.service
	systemctl enable flatpak-add-flathub-repo.service
	systemctl enable flatpak-replace-fedora-apps.service
	systemctl enable flatpak-cleanup.timer
	systemctl enable rpm-ostreed-automatic.timer

	sed -i 's/\.ext/.jxl/' /etc/dconf/db/local.d/01-background

    rpm-ostree install \
		https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
		https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
	rpm-ostree install rpmfusion-free-release rpmfusion-nonfree-release \
		--uninstall rpmfusion-free-release \
		--uninstall rpmfusion-nonfree-release
    rpm-ostree install broadcom-wl
	rpm-ostree install gnome-tweaks
	rpm-ostree override remove \
		gnome-classic-session \
		gnome-classic-session-xsession \
		gnome-shell-extension-apps-menu \
		gnome-shell-extension-launch-new-instance \
		gnome-shell-extension-places-menu \
		gnome-shell-extension-window-list \
		gnome-shell-extension-background-logo

	rpm-ostree cleanup -m && ostree container commit
EOT
