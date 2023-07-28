import groovy.json.JsonSlurperClassic;
import groovy.io.FileType

//--------CONSTANTS--------
def relativePathToPackageXml = 'changed-sources/package.xml'
def addOrUpdateChangesExistFileName = 'changesExist.txt'
def relativePathToClassesThatChanged = 'force-app/main/default/classes'
def relativePathToMapJson = 'unittest.json'
def testFileName = 'testsToRun.txt'
def relativePathToDesctructiveChangesXml = 'changed-sources/destructiveChanges/destructiveChanges.xml'
def deletesExistFileName = 'deletesExist.txt'

//--------SCRIPT--------
def changesExist = false;
def deletesExist = false;

println 'CHECKING '+relativePathToPackageXml+' for changes...'
def packageXml = new XmlSlurper().parse(relativePathToPackageXml)
changesExist=packageXml.types.size()>0;
if (changesExist) {
	println 'CREATING file '+addOrUpdateChangesExistFileName
	createFileWithContent(addOrUpdateChangesExistFileName,changesExist);
	def classesThatChanged = getListOfClassesThatChanged(packageXml)
	if (classesThatChanged.size()>0) {
		def testsToRun = getListOfTestClassesFromJson(classesThatChanged,relativePathToMapJson)
		if(testsToRun.size()>0) {
			addTests(testsToRun,testFileName);
		}
		else {	
			if(AllClassesAreTestClasses(classesThatChanged,relativePathToClassesThatChanged)){
				println 'All classes that changed appear to be test classes.'
			} else {
				def msg = 'There do NOT appear to be any tests for classes that changed. Consider associating test classes by updating '+relativePathToMapJson+'. If classes that changed are test classes, consider decorating them with the @isTest tag.'
				println msg
				throw new Exception(msg);		
			}
		}
	}
	else {
		println 'There do NOT appear to be any classes that changed.'		
	}	
}
else {
	println 'There do NOT appear to be any changes.'	
}

def desctructiveChangesXml = new XmlSlurper().parse(relativePathToDesctructiveChangesXml)
println 'CHECKING '+relativePathToDesctructiveChangesXml+' for deletes...'
deletesExist=desctructiveChangesXml.types.size()>0;
if (deletesExist) {
	println 'CREATING file '+deletesExistFileName
	createFileWithContent(deletesExistFileName,deletesExist);
}
else {
	println 'There do NOT appear to be any deletes.'	
}

return;

//--------FUNCTIONS--------

def AllClassesAreTestClasses(classes,relativePathToClassesThatChanged){
	for (c in classes) {
		if(!IsTestClass(c,relativePathToClassesThatChanged)) return false;
	}
	return true;
}

def IsTestClass(className,relativePathToClassesThatChanged){	
	String fileContents = new File(relativePathToClassesThatChanged+'/'+className+'.cls').text
	if(fileContents.contains('@isTest')) return true;
	return false;
}

def getListOfClassesThatChanged(packageXml){
	def classesThatChanged = []	
	println 'CHECKING for classes that changed...'
	def classNodes = packageXml.types.findAll { node ->		
		node.name.text() == "ApexClass"
	}
	for (n in classNodes){
		for (m in n.members){			
			def className = m.text()
			classesThatChanged << className;
			println "  "+className				
		}
	}
	
	return classesThatChanged;
}

def getListOfTestClassesFromJson(classesThatChanged,jsonPath){	
	println 'CHECKING '+jsonPath+' for tests to run...'
	def testClassesToReturn = []	
	def file = new File(jsonPath)
	def parsed = new JsonSlurperClassic().parse(file);
	
	///
	// Expected structure of the json file:
	// {
	//     "SomeClassName"🙁"SomeClassNameTest"],
	//     "SomeOtherClassName"🙁"SomeOtherClassNameTest","YetAnotherClassNameTest"]
	// }
	///
	for (changedClass in classesThatChanged) {
		println "  "+changedClass
		foundTests = parsed.get(changedClass);
		for (foundTest in foundTests) {			
			if (!testClassesToReturn.contains(foundTest)) {
				def shouldAdd = !testClassesToReturn.contains(foundTest)
				
				if (shouldAdd){
					println "    "+foundTest+" FLAGGED FOR INSERTION"
					testClassesToReturn.push(foundTest)
				}
				else{
					println "    "+foundTest+" ALREADY FLAGGED"
				}
			}
		}
	}	

	return testClassesToReturn;
}

def addTests(testsToRun,testFileName){
	def testToRunCommaDelimitedString="";
	def i=0;
	for (testToRun in testsToRun) {		
		if(i!=0){testToRunCommaDelimitedString+=','}
		testToRunCommaDelimitedString+=testToRun
		i++
	}			
	createFileWithContent(testFileName,testToRunCommaDelimitedString)
	println 'WRITING comma delim list of test class names to '+testFileName
	println "  "+testToRunCommaDelimitedString
}

def createFileWithContent(fileName,content){
	File file = new File(fileName)	
	file.write String.valueOf(content)
}