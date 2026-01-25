{
  buildPythonPackage,
  pytest-asyncio,
  pytestCheckHook,
  trame-client,
  trame-server,
  trame,
}:
buildPythonPackage {
  pname = "trame-server-tests";
  inherit (trame-server) version;

  pyproject = false;

  src = trame-server.testout;

  dontBuild = true;
  dontInstall = true;

  propagatedBuildInputs = [ trame-server ];

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
    trame
    trame-client
  ];
}
