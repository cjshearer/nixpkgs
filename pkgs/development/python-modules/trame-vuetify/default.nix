{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  fetchNpmDeps,
  fetchzip,
  nix-update-script,

  # build-system
  setuptools,

  # build
  nodejs,
  npmHooks,

  # dependencies
  trame-client,

  # tests
  pytestCheckHook,
  trame-server,
}:
buildPythonPackage (finalAttrs: {
  pname = "trame-vuetify";
  version = "3.2.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "Kitware";
    repo = "trame-vuetify";
    rev = "v${finalAttrs.version}";
    hash = "sha256-Z3E5KTdYmFdfkLHR4FIH3JX2NvQm+9whTRdFsv2gJyk=";
  };

  vuetifySrc = fetchzip {
    url = "https://registry.npmjs.org/vuetify/-/vuetify-3.11.2.tgz";
    hash = "sha256-HIVaQbqE0cThfMsBIuKWBFzO2r7mUmilpDVu/iAHRCU=";
    stripRoot = false;
  };

  mdiFontSrc = fetchzip {
    url = "https://registry.npmjs.org/@mdi/font/-/font-7.4.47.tgz";
    hash = "sha256-Q5QZ1I7A+OEXAViiJPENMEYRya19NRYV52L9HT1i/68=";
    stripRoot = false;
  };

  npmRoot = "vue2";

  npmDeps = fetchNpmDeps {
    inherit (finalAttrs) src;
    sourceRoot = "${finalAttrs.src.name}/${finalAttrs.npmRoot}";
    hash = "sha256-kmh7lmGnQzeQDN94LoF6V+Z3QzjV1+UF+SFOvjH6GYk=";
  };

  npmDepsVue3Lab = fetchNpmDeps {
    inherit (finalAttrs) src;
    sourceRoot = "vue3-lab";
    hash = "sha256-pazEqNzqc4DAYY/zuoc0yzaWFlr3pDGxhXauNrFxYCw=";
  };

  build-system = [ setuptools ];

  nativeBuildInputs = [
    nodejs
    npmHooks.npmConfigHook
  ];

  dependencies = [ trame-client ];

  nativeCheckInputs = [
    pytestCheckHook
    trame-server
  ];

  postPatch = ''
    # Ensure PEP 420 namespace package layout (split across trame-* packages)
    find trame -type f -name '__init__.py' -delete
  '';

  preBuild = ''
    # vue2 deps are installed by npmConfigHook (postPatchHooks)
    pushd ${finalAttrs.npmDeps.sourceRoot}
    npm run build
    popd

    export npmRoot="${finalAttrs.npmDepsVue3Lab.sourceRoot}"
    export npmDeps="${finalAttrs.npmDepsVue3Lab}"
    npmConfigHook

    pushd ${finalAttrs.npmDepsVue3Lab.sourceRoot}
    npm run build
    popd
  '';

  postFixup = ''
    pushd "$out"/lib/python*/site-packages/trame_vuetify/module

    mkdir -p vue3-serve/{css,fonts}
    pushd vue3-serve
    cp ${finalAttrs.vuetifySrc}/package/dist/vuetify.min.css vuetify3.css
    cp ${finalAttrs.vuetifySrc}/package/dist/vuetify.min.js vuetify3.js
    cp ${finalAttrs.mdiFontSrc}/package/css/materialdesignicons.min.css css/mdi.css
    cp ${finalAttrs.mdiFontSrc}/package/fonts/materialdesignicons-webfont.woff2 fonts/materialdesignicons-webfont.woff2
    popd

    mkdir -p vue3-lab-serve/{css,fonts}
    pushd vue3-lab-serve
    cp ${finalAttrs.mdiFontSrc}/package/css/materialdesignicons.min.css css/mdi.css
    cp ${finalAttrs.mdiFontSrc}/package/fonts/materialdesignicons-webfont.woff2 fonts/materialdesignicons-webfont.woff2
    popd

    popd
  '';

  pythonImportsCheck = [ "trame_vuetify" ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Vuetify widgets for trame";
    homepage = "https://github.com/Kitware/trame-vuetify";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ cjshearer ];
  };
})
