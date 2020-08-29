const scanner = require('sonarqube-scanner');
 
scanner(
  {
    serverUrl : 'https://eab-sonarqube.herokuapp.com/',
    token : `${process.env.CODE_QUALITY_TOKEN}`,
    options: {
      'sonar.projectName': 'myapp',
      'sonar.projectDescription': 'myapp express project',
      'sonar.sources': 'src',
      'sonar.tests': '__tests__'
    }
  },
  () => process.exit()
)