(function() {
  var GI_PER_LINE, ITERATION_NUM, deltaBytes, fs, pow10, showUsage;

  fs = require("fs");

  ITERATION_NUM = 100;

  GI_PER_LINE = 1.6741;

  module["export"] = function(gitaxfile, gi) {
    var buffer, bytes, fd, itr, line, linelen, resultGi, tax_id, _ref;
    fd = fs.openSync(gitaxfile, "r");
    tax_id = null;
    resultGi = 0;
    bytes = 0;
    linelen = 2 * (gi.toString().length + 6);
    itr = 0;
    while (!((resultGi === gi) || ++itr === ITERATION_NUM)) {
      bytes += deltaBytes(gi, resultGi, GI_PER_LINE);
      buffer = new Buffer(linelen);
      fs.readSync(fd, buffer, 0, linelen, bytes);
      line = buffer.toString().split("\n").reduce(function(line, mxline) {
        if (!mxline || line.length >= mxline.length) {
          return line;
        } else {
          return mxline;
        }
      });
      _ref = line.split("\t").map(Number), resultGi = _ref[0], tax_id = _ref[1];
    }
    if (itr === 100) {
      return null;
    } else {
      return tax_id;
    }
  };

  pow10 = function(m) {
    return Math.pow(10, m);
  };

  deltaBytes = function(a, b, r) {
    var A, AMagni, B, BMagni, R, i, rBytes, _i, _ref;
    A = Math.max(a, b);
    B = Math.min(a, b);
    R = r;
    rBytes = 0;
    AMagni = A.toString().length;
    BMagni = B.toString().length;
    if (AMagni > BMagni) {
      for (i = _i = BMagni, _ref = AMagni - 1; BMagni <= _ref ? _i <= _ref : _i >= _ref; i = BMagni <= _ref ? ++_i : --_i) {
        rBytes += (i + 6) * (pow10(i) - pow10(i - 1)) / R;
      }
    }
    rBytes += (AMagni + 6) * (A - Math.max(B, pow10(AMagni - 1)));
    if (a < b) {
      rBytes = -rBytes;
    }
    return parseInt(rBytes);
  };

  showUsage = function() {
    return console.error("\n[USAGE]\n\gitax <gi_tax_nucl.dmp> gi\n\n\tgi_tax_nucl.dmp: gi_tax data from ftp://ftp.ncbi.nih.gov/pub/taxonomy/\n\t result: tax_id to stdout");
  };

  exports.run = function() {
    var ap, e, file, gi, tax_id;
    try {
      ap = require("argparser").files(0).arglen(2, 2).nums(1).parse();
    } catch (_error) {
      e = _error;
      console.error("[ERROR]: " + e.message);
      showUsage();
      process.exit(1);
    }
    file = ap.arg(0);
    gi = ap.arg(1);
    tax_id = module["export"](file, gi);
    if (tax_id != null) {
      return console.log(tax_id);
    } else {
      return console.error("not found");
    }
  };

  if (require.main === module) {
    exports.run();
  }

}).call(this);
