#pragma once
#include <stdio.h>
#include <time.h>

class Logger {
private:
	FILE* file;

	void write(const char* type, const char* message) {
		time_t     now = time(0);
		struct tm  tstruct;
		char       buf[80];
		tstruct = *localtime(&now);
		strftime(buf, sizeof(buf), "%Y-%m-%d.%X", &tstruct);

		fprintf(file, "%15s - %10s - %s\n", buf, type, message);
		printf("%15s - %10s - %s\n", buf, type, message);
	}

public:
	Logger() {
		file = fopen("log.txt", "w");
	}

	void info(const char* message) {
		write("INFO", message);
	}

	void debug(const char* message) {
		write("DEBUG", message);
	}

	~Logger() {
		fclose(file);
	}

} LoggerSingelton;
