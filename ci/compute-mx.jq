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

def compute_image_name($x):
  ($x.IMAGE_REPO + if $build_type == "pull-request" then "-" + $pr_num + "-" else "" end) as $tag_prefix |
  (if $build_type == "pull-request" then "staging" else $x.IMAGE_REPO end) as $docker_repo |
  ("rapidsai/" + if $build_type == "pull-request" then $docker_repo + ":" + $tag_prefix else $x.IMAGE_REPO + ":" end) as $full_prefix |
  $full_prefix + "cuda" + $x.CUDA_VER + "-" + $x.LINUX_VER + "-" + "py" + $x.PYTHON_VER |
  $x + {IMAGE_NAME: .};


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
    compute_image_name(.)
  ] |
  {include: .};
