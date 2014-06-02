(function() {
  var showUsage;

  showUsage = function() {
    return console.error("\n[USAGE]\nsetting defualt files:\n\tgitax_set <gi_tax_nucl.dmp> [--names names.dmp]\n\nunset :\n\tgitax_set");
  };

  exports.run = function() {
    var ap, e, file, fs, gi_tax_nucl, json, names, path;
    try {
      ap = require("argparser").vals("names").parse();
    } catch (_error) {
      e = _error;
      console.error("[ERROR]: " + e.message);
      showUsage();
      process.exit(1);
    }
    gi_tax_nucl = ap.arg(0) || null;
    names = ap.opt("names") || null;
    path = require('path');
    fs = require('fs');
    file = path.join(path.dirname(fs.realpathSync(__filename)), '../.files.json');
    json = {
      gi_tax_nucl: gi_tax_nucl,
      names: names
    };
    console.error("[default files]");
    console.error(json);
    return fs.writeFileSync(file, JSON.stringify(json));
  };

  if (require.main === module) {
    exports.run();
  }

}).call(this);
