{
  buildPythonPackage,
  pillow,
  pixelmatch,
  playwright-driver,
  pytest-asyncio,
  pytest-playwright,
  pytest-xprocess,
  pytestCheckHook,
  trame-client,
  trame,
}:
buildPythonPackage {
  pname = "trame-client-tests";
  inherit (trame-client) version;

  pyproject = false;

  src = trame-client.testout;

  env.PLAYWRIGHT_BROWSERS_PATH = playwright-driver.browsers;

  dontBuild = true;
  dontInstall = true;

  propagatedBuildInputs = [ trame-client ];

  nativeCheckInputs = [
    pillow
    pixelmatch
    pytest-asyncio
    pytest-playwright
    pytest-xprocess
    pytestCheckHook
    trame
  ];
}
