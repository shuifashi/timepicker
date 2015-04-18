/** cited from: http://stackoverflow.com/questions/20793505/meteor-package-api-add-files-add-entire-folder **/
function getFilesFromFolder(packageName, folder){
    var _ = Npm.require("underscore");
    var fs = Npm.require("fs");
    var path = Npm.require("path");
    // helper function, walks recursively inside nested folders and return absolute filenames
    function walk(folder){
        var filenames = [];
        // get relative filenames from folder
        if (fs.existsSync(folder))
          var folderContent = fs.readdirSync(folder);
          // iterate over the folder content to handle nested folders
          _.each(folderContent,function(filename){
              // build absolute filename
              var absoluteFilename = folder + path.sep + filename;
              // get file stats
              var stat = fs.statSync(absoluteFilename);
              if(stat.isDirectory()){
                  // directory case  = > add filenames fetched from recursive call
                  filenames = filenames.concat(walk(absoluteFilename)); 
              }
              else{
                  // file case  = > simply add it
                  filenames.push(absoluteFilename);
              }
          });
        return filenames;
    }
    // save current working directory (something like "/home/user/projects/my-project")
    var cwd = process.cwd();
    // console.log("cwd: ", cwd);
    // chdir to our package directory
    var packagePath = "packages" + path.sep + packageName
    // console.log("packagePath: ", packagePath)
    process.chdir(packagePath);
    // launch initial walk
    var result = walk(folder);
    // console.log(folder + ': ' + result.join(', ') + '\n');
    // restore previous cwd
    process.chdir(cwd);
    return result;
}

Package.describe({
  name: 'ericwangqing:b-plus',
  version: '0.0.1_2',
  // Brief, one-line summary of the package.
  summary: '',
  // URL to the Git repository containing the source code for this package.
  git: '',
  // By default, Meteor will default to using README.md for documentation.
  // To avoid submitting documentation, set this field to null.
  documentation: 'README.md'
});

Package.onUse(function(api) {
  api.versionsFrom('1.0.3.1');
  // Jquery as a weak dependency, only if it's present, should load before a-plus
  api.use('jquery', 'client');
  api.use('ericwangqing:a-plus'); 
  api.use('amr:parsley.js');
  api.use(['templating'], 'client');
  api.addFiles(getFilesFromFolder('ericwangqing:b-plus', 'client'), 'client');
  api.addFiles(getFilesFromFolder('ericwangqing:b-plus', 'static'), 'client');
  api.addFiles(getFilesFromFolder('ericwangqing:b-plus', 'server'), 'server');
  api.addFiles(getFilesFromFolder('ericwangqing:b-plus', 'both'));
});

Package.onTest(function(api) { 
});
