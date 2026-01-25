{
  lib,
  buildPythonPackage,
  callPackage,
  fetchFromGitHub,
  nix-update-script,

  # build-system
  setuptools,

  # dependencies
  more-itertools,
  wslink,
}:
buildPythonPackage (finalAttrs: {
  pname = "trame-server";
  version = "3.10.0";
  pyproject = true;

  outputs = [
    "out"
    "testout"
  ];

  src = fetchFromGitHub {
    owner = "Kitware";
    repo = "trame-server";
    rev = "v${finalAttrs.version}";
    hash = "sha256-M3UQYJlo539y3M0LyxkHeQJgpVt+AkSXyjpVpukdV8w=j";
  };

  build-system = [ setuptools ];

  dependencies = [
    more-itertools
    wslink
  ];

  postInstall = ''
    mkdir $testout
    cp -R tests $testout/tests

    rm -rf "$out"/lib/python*/site-packages/{docs,examples,tests}
  '';

  doCheck = false;
  passthru.tests.trame-server-tests = callPackage ./tests.nix { };

  pythonImportsCheck = [ "trame_server" ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Internal server side implementation of trame";
    homepage = "https://github.com/Kitware/trame-server";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ cjshearer ];
  };
})
