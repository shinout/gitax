gitax
==========
gitax fetches taxonomy_id from given gi.

installation
----------------
```bash
$ npm install gitax
```

usage
-------------
command line
```bash
gi=1234567
tax_id=$(gitax /path/to/gi_tax_nucl.dmp $gi)
echo $tax_id
```

JavaScript API
```js
gitax = require("gitax")
tax_id = gitax("/path/to/gi_tax_nucl.dmp", 1234567);
```
