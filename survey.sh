
#!/bin/bash

SILENT=1
IGNORE_POINT=1
IGNORE_RC=1
survey_projects=(`ls projects/`)

redirect_cmd() {

    # write your test however you want; this just tests if SILENT is non-empty
    if [ -n "$SILENT" ]; then
        "$@" 2>/dev/null 1>/dev/null
    else
        "$@"
    fi

}

function analyze_version() {

    project=$1
    tag_name=$2
    tag_date=$3

    make=0
    headers=0
    c=0
    code=0
    col_name=""
    exclude=""

    [[ -f "quirks/$project.ignore" ]] && exclude="--exclude-list-file=quirks/$project.ignore"

    readarray -t cloc_output <<< `deps/cloc/cloc $exclude projects/$project | egrep '^C |Header|make|CMake'`
    for i in "${cloc_output[@]}";
    do
	values=($i)
	last_col=${#values[@]}

	for ((e=0;e<last_col-4;e++));
	do
	    col_name="$col_name ${values[e]}"
	done

	case "$col_name" in
	    " C/C++ Header")
		headers=$((values[last_col-1]))
		;;
	    " C")
		c=$((values[last_col-1]))
		;;
    	    " C++")
		c=$((values[last_col-1]))
		;;
	    " make")
		make=$((values[last_col-1]))
		;;
	    " CMake")
		make=$((values[last_col-1]))
		;;
	esac

	col_name=""
	code=$((code+values[last_col-1]))
    done

    printf "%20s %10s %20s %8d %8d %8d %8d\n" $project $tag_date $tag_name $code $c $headers $make

}

function checkout_version() {

    project=$1
    tag_name=$2

    redirect_cmd git -C projects/$project reset --hard
    redirect_cmd git -C projects/$project clean -f -d
    redirect_cmd git -C projects/$project checkout -b local-$tag_name $tag_name
}

function delete_branch() {

   project=$1
   tag_name=$2

   redirect_cmd git -C projects/$project checkout master
   redirect_cmd git -C projects/$project branch -D local-$tag_name
}

while getopts "hspv" arg; do
    case $arg in
	h)
	    echo "//TODO"
	    ;;
	v)
	    unset SILENT
	    ;;
	p)
	    IGNORE_POINT=0
	    ;;
	r)
	    IGNORE_RC=0
	    ;;
    esac
done

printf "%20s %10s %20s %8s %8s %8s %8s\n" "Project" "Date" "Version" "Code" "C" "Headers" "Make"
for project in ${survey_projects[@]};
do
   readarray -t project_tag_date <<< `git -C projects/$project for-each-ref --sort=taggerdate --format '%(refname),%(taggerdate:short),%(committerdate:short)' refs/tags`

   for tag_date in ${project_tag_date[@]};
   do

       tag_data=($(echo $tag_date | sed 's/,/ /g'))
       tag=$(echo ${tag_data[0]} | sed 's/refs\/tags\///')

       [[ $IGNORE_RC == 1 && ( $tag == *"rc"* ||  $tag == *"pre"* ) ]] && continue
       [[ $IGNORE_POINT == 1 && $tag =~ ([0-9]+\.){2}([0-9]+) && ${BASH_REMATCH[2]} > 0 ]] && continue

       if [[ -z ${tag_data[1]} ]]
       then
	   tag_date=${tag_data[2]}
       else
	   tag_date=${tag_data[1]}
       fi

       checkout_version $project $tag $tag_date

       analyze_version $project $tag $tag_date

       delete_branch $project $tag $tag_date
   done
done
