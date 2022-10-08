param (
  [Parameter()]
  [string]$inkscapeBin = 'C:\Program Files\Inkscape\bin\inkscape.com',
  [Parameter()]
  [switch]$generateAll,
  [Parameter()]
  [string[]]$categories
)
Write-Host "Started"
$FONT_AWESOME_DIR = "$PSScriptRoot\lib\fontawesome-free-6.2.0-desktop\fontawesome-free-6.2.0-desktop"
$import_svg_path = Get-Item "$PSScriptRoot\icon-import.svg"
Write-Host "Generate All Switch: ${generateAll}"
Write-Host "Font Awesome Dir: ${FONT_AWESOME_DIR}"
Write-Host "Temp Icon Path: ${import_svg_path}"
Write-Host "Categories:"
for ( $i = 0; $i -lt $categories.count; $i++ ) {
    Write-Host "  $($categories[$i])"
}

$categories_json = yq --output-format="json" "." "$FONT_AWESOME_DIR\metadata\categories.yml"
$categories_ref = $categories_json | ConvertFrom-Json
Write-Host "Categories parsed"

Write-Host ""
foreach($category_node in $categories_ref.psobject.Properties) {
    $category = $category_node.Name
    Write-Host "Generating for `"$category`"..."
    if (!($generateAll.IsPresent) -and ($category -notin $categories)) {
      continue
    }

    $category_folder = "$PSScriptRoot\output\$category"
    if (-Not (Test-Path $category_folder)) {
      #PowerShell Create directory if not exists
      New-Item $category_folder -ItemType Directory
      Write-Host "  Category directory created"
    } else {
      Write-Host "  Category directory exists"
    }

    # Copy over LICENSE
    Copy-Item "${PSScriptRoot}\LICENSE_template.txt" "${category_folder}\LICENSE"
    Write-Host "  LICENSE copied"

    # Copy and modify README
    $readme_path = "${category_folder}\README.md"
    Copy-Item "${PSScriptRoot}\README_template.md" "${readme_path}"
    Write-Host "  README copied"
    (Get-Content -Path $readme_path).replace('[$category-label$]', $category_node.Value.label) | Set-Content -Path $readme_path
    Write-Host "  README tokens replaced"

    foreach ($icon in $category_node.Value.icons) {
      Copy-Item "${FONT_AWESOME_DIR}\svgs\*\${icon}.svg" $import_svg_path
      Write-Host "  Icon `"$icon`" copied to Temp Icon Path"
      & "$inkscapeBin" --actions="select-clear; export-area-drawing; export-type:png; export-width:200; export-height:200; select-by-id:icon; object-align:hcenter vcenter drawing; select-by-id:inactive; select-by-id:active; object-set-attribute:style,display:inline; export-filename:${PSScriptRoot}\output\${category}\${icon}_Active; export-do; select-clear; select-by-id:active; object-set-attribute:style,display:none; export-filename:${PSScriptRoot}\output\${category}\${icon}_Inactive; export-do; select-clear; select-by-id:inactive; object-set-attribute:style,display:none; export-filename:${PSScriptRoot}\output\${category}\${icon}_Clear; export-do;" "$PSScriptRoot\Icon_Powered_Steel.svg"
      Write-Host "  Icon `"$icon`" generated"
    }

    Write-Host "Icons generated for `"$category`""
    Write-Host ""
}