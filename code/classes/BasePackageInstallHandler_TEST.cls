@isTest
private class BasePackageInstallHandler_TEST {

    /////////////////////////////////////////////////////////////////////////
    //Test Case: validateUpdate
    /////////////////////////////////////////////////////////////////////////
	@isTest static void validateUpdate(){

        BasePackageInstallHandler postInstall = new BasePackageInstallHandler();

        Test.testInstall(postInstall, new Version(1,0));


    }
    /////////////////////////////////////////////////////////////////////////
    //Test Case: validateInstall
    /////////////////////////////////////////////////////////////////////////
	@isTest static void validateInstall(){
        BasePackageInstallHandler postInstall = new BasePackageInstallHandler();
        Test.testInstall(postInstall, null);

    }
    /////////////////////////////////////////////////////////////////////////
    //Test Case: validatePushUpgrade
    /////////////////////////////////////////////////////////////////////////
	@isTest static void validatePushUpgrade(){
        BasePackageInstallHandler postInstall = new BasePackageInstallHandler();
        Test.testInstall(postInstall, new Version(1,0), true);

    }

}