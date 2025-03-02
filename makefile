watch-test:
	fswatch -o -1 -u -t "src" "test" | xargs -n1 -I{} sh -c 'gleam test'

watch-docs:
	fswatch -o -1 -u -t "src" "test" | xargs -n1 -I{} sh -c 'gleam docs build'
