gitax
==========
gitax fetches taxonomy_id from given NCBI gi.

installation
----------------
```bash
$ npm install -g gitax
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

gi_tax_nucl.dmp?
------------------
a file which describes relations between gi and taxonomy_id

download one from ftp://ftp.ncbi.nih.gov/pub/taxonomy/

```bash
wget -r ftp://ftp.ncbi.nih.gov/pub/taxonomy/
```
