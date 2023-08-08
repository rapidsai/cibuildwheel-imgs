def compute_arch($x):
  ["amd64"] |
  if
    ["ubuntu18.04", "centos7"] | any(index($x.LINUX_VER))
  then
    .
  else
    . + ["arm64"]
  end |
  $x + {ARCHES: .};

# Checks the current entry to see if it matches the given exclude
def matches($entry; $exclude):
  all($exclude | to_entries | .[]; $entry[.key] == .value);

def compute_tag_prefix($x):
  if $build_type == "pull-request" then
    $x.IMAGE_REPO + "-" + $pr_num + "-"
  else
    ""
  end |
  $x + {TAG_PREFIX: .};

def compute_used_repo($x):
  if $build_type == "pull-request" then
    "staging"
  else
    $x.IMAGE_REPO
  end |
  $x + {USED_REPO: .};

def compute_full_prefix($x):
  if $build_type == "pull-request" then
    "rapidsai/"+$x.USED_REPO+":"+$x.TAG_PREFIX
  else
    "rapidsai/" + $x.IMAGE_REPO + ":"
  end |
  $x + {FULL_PREFIX: .};

# Checks the current entry to see if it matches any of the excludes.
# If so, produce no output. Otherwise, output the entry.
def filter_excludes($entry; $excludes):
  select(any($excludes[]; matches($entry; .)) | not);

def lists2dict($keys; $values):
  reduce range($keys | length) as $ind ({}; . + {($keys[$ind]): $values[$ind]});

def compute_mx($input):
  ($input.exclude // []) as $excludes |
  $input | del(.exclude) |
  keys_unsorted as $mx_keys |
  to_entries |
  map(.value) |
  [
    combinations |
    lists2dict($mx_keys; .) |
    filter_excludes(.; $excludes) |
    compute_arch(.) |
    compute_tag_prefix(.) |
    compute_used_repo(.) |
    compute_full_prefix(.)
  ] |
  {include: .};
