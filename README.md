# rh_exam_prep
setup scripts and notes

## Setup

```
mkdir modules/ci-env/
rsync -avP /path/to/my-sensitive-data/ modules/ci-env/
rsync -avP /path/tp/my-env-data/       modules/ci-env/
make init
make plan
make apply
...
```

