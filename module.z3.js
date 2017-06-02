(function (root, factory) {
  if (typeof define === 'function' && define.amd) {
    // AMD
    define(["./loader"], factory);
  } else if (typeof exports === 'object') {
    // Node, CommonJS-like
    module.exports = factory(require("./loader"));
  } else {
    // Browser globals (root is window)
    root.z3 = factory(root.loadModule);
  }
}(this, function (loadModule) {
  return function loadZ3(directory) {
    return new Promise(function(resolve, reject) {
      loadModule("z3.js", directory).then(function(z3) {
        var memFileTimeOut = 1000;
        setTimeout(function() {

          z3.query = function query(problem, fileName) {
            if (!fileName) {
              fileName = "problem.smt2";
            }

            var oldConsoleLog = console.log;
            var stdout = [];
            window.console.log = function(solution) {
              stdout.push(solution);
              // oldConsoleLog.apply(console, arguments);
            }

            z3.FS.createDataFile("/", fileName, "(check-sat) " + problem, !0, !0);

            try {
              z3.Module.callMain(["-smt2", "/" + fileName])
            } catch (exception) {
              console.error("exception", exception);
            } finally {
              z3.FS.unlink("/" + fileName)
            }

            window.console.log = oldConsoleLog;

            return stdout.filter(function (line) { return !line.startsWith("WARNING");}).splice(1).join('\n');
          };
          resolve(z3);
        }, memFileTimeOut);
      });
    });
  };
}));
