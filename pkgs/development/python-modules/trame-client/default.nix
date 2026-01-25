{
  lib,
  buildPythonPackage,
  callPackage,
  fetchFromGitHub,
  fetchNpmDeps,
  nix-update-script,

  # build-system
  setuptools,

  # build
  nodejs,
  npmHooks,

  # dependencies
  trame-common,
}:
buildPythonPackage (finalAttrs: {
  pname = "trame-client";
  version = "3.11.2";
  pyproject = true;

  outputs = [
    "out"
    "testout"
  ];

  src = fetchFromGitHub {
    owner = "Kitware";
    repo = "trame-client";
    rev = "v${finalAttrs.version}";
    hash = "sha256-ykzTIUx8jPdIyEBtZalbiZUPuXqLlb1MARq9o2Igi1o=";
  };

  npmRoot = "vue2-app";

  npmDeps = fetchNpmDeps {
    inherit (finalAttrs) src;
    sourceRoot = finalAttrs.npmRoot;
    hash = "sha256-qEsybpSBElUzmqCLui3DVVfBtfiLscV+SULdSGlNwck=";
  };

  npmDepsVue3 = fetchNpmDeps {
    inherit (finalAttrs) src;
    sourceRoot = "vue3-app";
    hash = "sha256-bMdNCMx6aTCgyxSBQZ7EJdBOptntW3FmBt7mfjecn7w=";
  };

  build-system = [ setuptools ];

  nativeBuildInputs = [
    nodejs
    npmHooks.npmConfigHook
  ];

  dependencies = [ trame-common ];

  postPatch = ''
    # Ensure PEP 420 namespace package layout (split across trame-* packages)
    find trame -type f -name '__init__.py' -delete
  '';

  preBuild = ''
    # vue2-app deps are installed by npmConfigHook (postPatchHooks)
    pushd ${finalAttrs.npmDeps.sourceRoot}
    npm run build
    popd

    export npmRoot="${finalAttrs.npmDepsVue3.sourceRoot}"
    export npmDeps="${finalAttrs.npmDepsVue3}"
    npmConfigHook

    pushd ${finalAttrs.npmDepsVue3.sourceRoot}
    npm run build
    popd
  '';

  postInstall = ''
    mkdir $testout
    cp -R tests examples $testout/

    rm -rf "$out"/lib/python*/site-packages/{examples,js-lib,tests}
  '';

  doCheck = false;
  passthru.tests.trame-client-tests = callPackage ./tests.nix { };

  pythonImportsCheck = [ "trame_client" ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Internal client of trame";
    homepage = "https://github.com/Kitware/trame-client";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ cjshearer ];
  };
})
