{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  nix-update-script,

  # build-system
  setuptools,

  # dependencies
  pyyaml,
  trame-server,
  trame-client,
  trame-common,
  wslink,

  # tests
  pytestCheckHook,
}:
buildPythonPackage (finalAttrs: {
  pname = "trame";
  version = "3.12.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "Kitware";
    repo = "trame";
    rev = "v${finalAttrs.version}";
    hash = "sha256-U58Tq4/NVcFCZ2vTjilbabnbQhlEf2QS/e/7Zy5l5YU=";
  };

  build-system = [ setuptools ];

  dependencies = [
    trame-server
    trame-client
    trame-common
    wslink
    pyyaml
  ];

  nativeCheckInputs = [ pytestCheckHook ];

  preBuild = ''
    # Ensure PEP 420 namespace package layout (split across trame-* packages)
    for d in trame trame/modules trame/ui trame/widgets; do
      rm "$d/__init__.py"
    done
  '';

  pythonImportsCheck = [ "trame" ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Framework to build applications in plain Python";
    homepage = "https://github.com/Kitware/trame";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ cjshearer ];
  };
})
