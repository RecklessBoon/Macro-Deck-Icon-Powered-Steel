param (
  [switch]$generateAll = $false
)
$FONT_AWESOME_DIR = "$PSScriptRoot\lib\fontawesome-free-6.2.0-desktop\fontawesome-free-6.2.0-desktop"
$import_svg_path = Get-Item "$PSScriptRoot\icon-import.svg"

$categories_json = yq --output-format="json" "." "$FONT_AWESOME_DIR\metadata\categories.yml"
$categories = $categories_json | ConvertFrom-Json

foreach($category_node in $categories.psobject.Properties) {
    $category = $category_node.Name
    if (($generateAll.Equals($false)) -And -Not ($args.contains($category))) {
      continue
    }

    $category_folder = "$PSScriptRoot\output\$category"
    if (-Not (Test-Path $category_folder)) {
        #PowerShell Create directory if not exists
        New-Item $category_folder -ItemType Directory
    }

    # Copy over LICENSE
    Copy-Item "${PSScriptRoot}\LICENSE_template.txt" "${category_folder}\LICENSE"

    # Copy and modify README
    $readme_path = "${category_folder}\README.md"
    Copy-Item "${PSScriptRoot}\README_template.md" "${readme_path}"
    (Get-Content -Path $readme_path).replace('[$category-label$]', $category_node.Value.label) | Set-Content -Path $readme_path

    foreach ($icon in $category_node.Value.icons) {
      Copy-Item "${FONT_AWESOME_DIR}\svgs\*\${icon}.svg" $import_svg_path
      & 'C:\Program Files\Inkscape\bin\inkscape.com' --actions="select-clear; export-area-drawing; export-type:png; export-width:200; export-height:200; select-by-id:icon; object-align:hcenter vcenter drawing; select-by-id:inactive; select-by-id:active; object-set-attribute:style,display:inline; export-filename:${PSScriptRoot}\output\${category}\${icon}_Active; export-do; select-clear; select-by-id:active; object-set-attribute:style,display:none; export-filename:${PSScriptRoot}\output\${category}\${icon}_Inactive; export-do; select-clear; select-by-id:inactive; object-set-attribute:style,display:none; export-filename:${PSScriptRoot}\output\${category}\${icon}_Clear; export-do;" "$PSScriptRoot\Icon_Powered_Steel.svg"
    }
}