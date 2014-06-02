(function() {
  var BYTE_PER_LINE, GI_PER_LINE, ITERATION_NUM, TI_PER_LINE, estimateByteFromGi, fs, getGiFromByte, getNames, getTaxId, getTiFromByte, pow10;

  require("termcolor").define;

  fs = require("fs");

  ITERATION_NUM = 100;

  GI_PER_LINE = 1.6741;

  TI_PER_LINE = 0.8687;

  BYTE_PER_LINE = 58.03;

  module.exports = function(gi, gitaxfile, namesfile) {
    var names, tax_id;
    tax_id = getTaxId(gi, gitaxfile);
    if (namesfile === null || tax_id === null) {
      return tax_id;
    }
    names = getNames(tax_id, namesfile);
    return {
      tax_id: tax_id,
      names: names
    };
  };

  getTaxId = function(gi, gitaxfile) {
    var estimatedByte, fd, filesize, itr, left, resultGi, right, tax_id, _ref;
    filesize = fs.statSync(gitaxfile).size;
    fd = fs.openSync(gitaxfile, "r");
    itr = 0;
    left = 0;
    right = filesize;
    resultGi = 0;
    tax_id = null;
    estimatedByte = estimateByteFromGi(gi, GI_PER_LINE);
    while (!(resultGi === gi || ++itr === ITERATION_NUM)) {
      _ref = getGiFromByte(estimatedByte, gi, fd), resultGi = _ref[0], tax_id = _ref[1];
      if (resultGi > gi) {
        right = estimatedByte;
      } else {
        left = estimatedByte;
      }
      estimatedByte = Math.floor((left + right) / 2);
    }
    fs.closeSync(fd);
    if (itr === 100) {
      return null;
    } else {
      return tax_id;
    }
  };

  getNames = function(tax_id, namesfile) {
    var buffer, estimatedByte, fd, filesize, itr, left, line, linelen, lines, name, name_class, names, resultTi, right, uniq_name, _i, _len, _ref;
    filesize = fs.statSync(namesfile).size;
    fd = fs.openSync(namesfile, "r");
    itr = 0;
    left = 0;
    right = filesize;
    estimatedByte = BYTE_PER_LINE * tax_id / TI_PER_LINE;
    resultTi = 0;
    linelen = 4 * BYTE_PER_LINE;
    while (!((resultTi === tax_id) || ++itr === ITERATION_NUM)) {
      buffer = new Buffer(linelen);
      fs.readSync(fd, buffer, 0, linelen, estimatedByte);
      line = buffer.toString().split("\n")[1];
      resultTi = Number(line.split("|").map(function(v) {
        return v.trim();
      }).shift());
      if (resultTi > tax_id) {
        right = estimatedByte;
      } else {
        left = estimatedByte;
      }
      estimatedByte = Math.floor((left + right) / 2);
    }
    if (itr === 100) {
      fs.closeSync(fd);
      return null;
    }
    buffer = new Buffer(linelen * 6);
    fs.readSync(fd, buffer, 0, linelen * 6, estimatedByte - linelen * 3);
    lines = buffer.toString().split("\n");
    names = [];
    for (_i = 0, _len = lines.length; _i < _len; _i++) {
      line = lines[_i];
      _ref = line.split("|").map(function(v) {
        return v.trim();
      }), resultTi = _ref[0], name = _ref[1], uniq_name = _ref[2], name_class = _ref[3];
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
    if (names.length === 0) {
      return null;
    } else {
      return names;
    }
  };

  pow10 = function(m) {
    return Math.pow(10, m);
  };

  estimateByteFromGi = function(gi, R) {
    var byte, i, magni, _i, _ref;
    byte = 0;
    magni = gi.toString().length;
    for (i = _i = 1, _ref = magni - 1; 1 <= _ref ? _i <= _ref : _i >= _ref; i = 1 <= _ref ? ++_i : --_i) {
      byte += (i + 6) * (pow10(i) - pow10(i - 1)) / R;
    }
    byte += (magni + 6) * (gi - pow10(magni - 1)) / R;
    return parseInt(byte);
  };

  getGiFromByte = function(byte, gi, fd) {
    var buffer, line, linelen;
    linelen = 3 * (gi.toString().length + 6);
    buffer = new Buffer(linelen);
    fs.readSync(fd, buffer, 0, linelen, byte);
    line = buffer.toString().split("\n")[1];
    return line.split("\t").map(Number);
  };

  getTiFromByte = function(byte, fd) {
    var buffer, line, linelen;
    linelen = 3 * (gi.toString().length + 6);
    buffer = new Buffer(linelen);
    fs.readSync(fd, buffer, 0, linelen, byte);
    line = buffer.toString().split("\n")[1];
    return line.split("\t").map(Number);
  };

}).call(this);
