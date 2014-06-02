(function() {
  var BYTE_PER_LINE, GI_PER_LINE, ITERATION_NUM, TI_PER_LINE, deltaBytes, fs, pow10;

  fs = require("fs");

  ITERATION_NUM = 100;

  GI_PER_LINE = 1.6741;

  TI_PER_LINE = 0.8687;

  BYTE_PER_LINE = 58.03;

  module.exports = function(gi, gitaxfile, namesfile) {
    var buffer, bytes, fd, itr, line, linelen, lines, name, name_class, names, resultGi, resultTi, tax_id, tax_names, uniq_name, _i, _len, _ref, _ref1, _ref2;
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
    fs.closeSync(fd);
    if (itr === 100) {
      return null;
    }
    if (!namesfile) {
      return tax_id;
    }
    fd = fs.openSync(namesfile, "r");
    tax_names = [];
    resultTi = 0;
    bytes = 0;
    linelen = 4 * BYTE_PER_LINE;
    itr = 0;
    while (!((resultTi === tax_id) || ++itr === ITERATION_NUM)) {
      bytes += BYTE_PER_LINE * (tax_id - resultTi) / TI_PER_LINE;
      buffer = new Buffer(linelen);
      fs.readSync(fd, buffer, 0, linelen, bytes);
      line = buffer.toString().split("\n").reduce(function(line, mxline) {
        if (!mxline || line.length >= mxline.length) {
          return line;
        } else {
          return mxline;
        }
      });
      _ref1 = line.split("|").map(function(v) {
        return v.trim();
      }), resultTi = _ref1[0], name = _ref1[1], uniq_name = _ref1[2], name_class = _ref1[3];
      resultTi = Number(resultTi);
    }
    if (itr === 100) {
      fs.closeSync(fd);
      return {
        tax_id: tax_id,
        names: null
      };
    }
    buffer = new Buffer(linelen * 6);
    fs.readSync(fd, buffer, 0, linelen * 6, bytes - linelen * 3);
    lines = buffer.toString().split("\n");
    names = [];
    for (_i = 0, _len = lines.length; _i < _len; _i++) {
      line = lines[_i];
      _ref2 = line.split("|").map(function(v) {
        return v.trim();
      }), resultTi = _ref2[0], name = _ref2[1], uniq_name = _ref2[2], name_class = _ref2[3];
      resultTi = Number(resultTi);
      if (resultTi === tax_id) {
        names.push({
          name: name,
          uniq_name: uniq_name,
          name_class: name_class
        });
      }
    }
    fs.closeSync(fd);
    return {
      tax_id: tax_id,
      names: names.length === 0 ? null : names
    };
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

}).call(this);
