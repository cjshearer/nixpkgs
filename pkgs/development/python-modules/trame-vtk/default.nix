{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  fetchurl,
  nix-update-script,

  # build-system
  hatchling,

  # dependencies
  trame-client,
  vtk,

  # tests
  nest-asyncio,
  pillow,
  pixelmatch,
  pytest-asyncio,
  pytest-playwright,
  pytest-xprocess,
  pytestCheckHook,
  pyvista,
  trame,
  trame-vuetify,
}:
buildPythonPackage (finalAttrs: {
  pname = "trame-vtk";
  version = "2.11.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "Kitware";
    repo = "trame-vtk";
    rev = "v${finalAttrs.version}";
    hash = "sha256-cnLV4gUojKjjUby3tH29GSAGpLe+b+yqQgWtKuyAHoA=";
  };

  vueVtkJs = fetchurl {
    url = "https://unpkg.com/vue-vtk-js@3.3.4";
    hash = "sha256-lIsMyhZ7wuIxWk0e8Y6yPL5ZecgG+7fwsVftfA5e0oA=";
  };

  offlineLocalView = fetchurl {
    url = "https://raw.githubusercontent.com/Kitware/vtk-js/2d8de2853a1e63c12f9682acb3531083b77c4e3d/examples/OfflineLocalView/OfflineLocalView.html";
    hash = "sha256-4lIdZqVXm22bD/nX9pnCXFtuWQJk2B0IQ8GWQgOaWpw=";
  };

  build-system = [ hatchling ];

  propagatedBuildInputs = [
    trame-client
    vtk
  ];

  nativeCheckInputs = [
    nest-asyncio
    pillow
    pixelmatch
    pytest-asyncio
    pytest-playwright
    pytest-xprocess
    pytestCheckHook
    pyvista
    trame
    trame-vuetify
  ];

  disabledTests = [
    # I think this requires osmesa, which was removed:
    # https://gitlab.freedesktop.org/mesa/mesa/-/merge_requests/33836
    "test_rendering"
  ];

  postPatch = ''
    # Ensure PEP 420 namespace package layout (split across trame-* packages)
    find src/trame -type f -name '__init__.py' -delete
  '';

  preBuild = ''
    mkdir -p src/trame_vtk/modules/common/serve

    ln -s ${finalAttrs.vueVtkJs} src/trame_vtk/modules/common/serve/trame-vtk.js
    ln -s ${finalAttrs.offlineLocalView} src/trame_vtk/tools/static_viewer.html
  '';

  pythonImportsCheck = [ "trame_vtk" ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "VTK widgets for trame";
    homepage = "https://github.com/Kitware/trame-vtk";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ cjshearer ];
  };
})
