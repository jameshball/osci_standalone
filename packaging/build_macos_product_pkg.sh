#!/usr/bin/env bash
set -euo pipefail

usage() {
    echo "Usage: $0 --root DIR --product NAME --version VERSION --build-dir DIR --bundle-id ID --output FILE [--resource FILE ...]" >&2
    exit 2
}

root_dir=""
product=""
version=""
build_dir=""
bundle_id=""
output=""
resources=()
while (($#)); do
    case "$1" in
        --root) root_dir="$2"; shift 2 ;;
        --product) product="$2"; shift 2 ;;
        --version) version="$2"; shift 2 ;;
        --build-dir) build_dir="$2"; shift 2 ;;
        --bundle-id) bundle_id="$2"; shift 2 ;;
        --output) output="$2"; shift 2 ;;
        --resource) resources+=("$2"); shift 2 ;;
        *) usage ;;
    esac
done

for value in "$root_dir" "$product" "$version" "$build_dir" "$bundle_id" "$output"; do
    [[ -n "$value" ]] || usage
done

application_identity="${OSCI_CODESIGN_IDENTITY:-Developer ID Application: James Ball (D86A3M3H2L)}"
installer_identity="${OSCI_INSTALLER_SIGNING_IDENTITY:-Developer ID Installer: James Ball (D86A3M3H2L)}"
notary_profile="${OSCI_NOTARY_PROFILE:-}"
skip_notarization="${OSCI_SKIP_NOTARIZATION:-0}"
skip_package_signing="${OSCI_SKIP_PACKAGE_SIGNING:-0}"
stage_dir="$root_dir/packaging/build/${product}-macos-components"
bundle_stage="$stage_dir/bundles"
component_stage="$stage_dir/components"

rm -rf "$stage_dir"
rm -f "$output"
mkdir -p "$bundle_stage" "$component_stage" "$(dirname "$output")"

bundle_names=("$product.app" "$product.vst3" "$product.component")
install_locations=("/Applications" "/Library/Audio/Plug-Ins/VST3" "/Library/Audio/Plug-Ins/Components")
component_names=("standalone" "vst3" "au")

package_args=()
for index in "${!bundle_names[@]}"; do
    source_bundle="$build_dir/${bundle_names[$index]}"
    [[ -d "$source_bundle" ]] || { echo "Missing release bundle: $source_bundle" >&2; exit 1; }
    staged_bundle="$bundle_stage/${bundle_names[$index]}"
    cp -R "$source_bundle" "$staged_bundle"
    mkdir -p "$staged_bundle/Contents/Resources"
    for resource in "${resources[@]}"; do
        [[ -f "$resource" ]] || { echo "Missing package resource: $resource" >&2; exit 1; }
        cp "$resource" "$staged_bundle/Contents/Resources/"
    done
    codesign --force --deep --options runtime --timestamp --sign "$application_identity" "$staged_bundle"
    codesign --verify --deep --strict --verbose=2 "$staged_bundle"

    component_package="$component_stage/${component_names[$index]}.pkg"
    pkgbuild --component "$staged_bundle" --install-location "${install_locations[$index]}" \
        --identifier "$bundle_id.pkg.${component_names[$index]}" --version "$version" "$component_package"
    package_args+=(--package "$component_package")
done

if [[ "$skip_package_signing" == "1" ]]; then
    productbuild "${package_args[@]}" "$output"
else
    productbuild --sign "$installer_identity" "${package_args[@]}" "$output"
    pkgutil --check-signature "$output"
fi

if [[ "$skip_notarization" != "1" ]]; then
    [[ "$skip_package_signing" != "1" ]] || { echo "Notarization requires a signed installer package." >&2; exit 1; }
    [[ -n "$notary_profile" ]] || {
        echo "Set OSCI_NOTARY_PROFILE to a notarytool keychain profile, or OSCI_SKIP_NOTARIZATION=1 for local package testing." >&2
        exit 1
    }
    xcrun notarytool submit "$output" --keychain-profile "$notary_profile" --wait
    xcrun stapler staple "$output"
    xcrun stapler validate "$output"
fi
