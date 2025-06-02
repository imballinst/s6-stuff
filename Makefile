build:
	docker build -t demo --progress=plain .

build-without-cache:
	docker build -t demo --progress=plain --no-cache .

run:
	docker run -p 8080:8080 -p 8081:8081 demo