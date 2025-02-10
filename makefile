###############################################################################
# Pull in PETSc configuration
###############################################################################
include ${PETSC_DIR}/lib/petsc/conf/variables
include ${PETSC_DIR}/lib/petsc/conf/rules

###############################################################################
# Directories and common settings
###############################################################################
.DEFAULT_GOAL := all

BUILD         := ./build
OBJ_DIR       := $(BUILD)/objects
APP_DIR       := $(BUILD)/apps
TEST_DIR      := $(BUILD)/tests

HTML_DIR	  := ./html
LATEX_DIR	  := ./latex

# Include paths
INCLUDE       := -Iinclude -I${PETSC_DIR}/include -I/usr/local/include

# Google Test link libraries
GTEST_LIB     := -lgtest -lgtest_main -pthread

# Collect all "library" source files in `src/` (excluding `src/apps`)
SRCS          := $(wildcard src/*.cc)

# Collect all application files in `src/apps/`
APPS_SRCS     := $(wildcard src/apps/*.cc)

# Collect all test source files in `tests/` (recursively if desired)
TESTS_SRCS    := $(wildcard tests/**/*.cc)

###############################################################################
# Object files
###############################################################################
# Convert `x.cc` -> `build/objects/x.o`
OBJS          := $(SRCS:%.cc=$(OBJ_DIR)/%.o)
APPS_OBJS     := $(APPS_SRCS:%.cc=$(OBJ_DIR)/%.o)
TESTS_OBJS    := $(TESTS_SRCS:%.cc=$(OBJ_DIR)/%.o)

# Gather dependencies from each .o’s .d file
DEPENDENCIES  := $(OBJS:.o=.d) $(APPS_OBJS:.o=.d) $(TESTS_OBJS:.o=.d)

###############################################################################
# Executables
###############################################################################
# For each `src/apps/foo.cc`, we produce `build/apps/foo`.
APPS_BIN      := $(patsubst src/apps/%.cc,$(APP_DIR)/%,$(APPS_SRCS))

# For tests in `tests/foo.cc` → `build/tests/foo`.
TESTS_BIN     := $(patsubst tests/%.cc,$(TEST_DIR)/%,$(TESTS_SRCS))

###############################################################################
# Phony rules
###############################################################################
.PHONY: all apps tests build clean cleanall

all: build apps

# Create output directories if needed
build:
	@mkdir -p $(OBJ_DIR)
	@mkdir -p $(APP_DIR)
	@mkdir -p $(TEST_DIR)

apps: $(APPS_BIN)

# Build and run all tests
test: $(TESTS_BIN)
	@echo "==== Running all tests ===="
	@set -e; \
	for t in $(TESTS_BIN); do \
		echo "Running $$t..."; \
		$$t || exit 1; \
	done
	@echo "==== All tests PASSED ===="

###############################################################################
# Pattern rules for compiling .cc → .o
###############################################################################
# Compile any file X.cc into X.o (also produce a .d dependency file)
$(OBJ_DIR)/%.o: %.cc
	@mkdir -p $(@D)
	-$(CXXLINKER) -c -Wall $< -MMD -o $@ $(INCLUDE)

###############################################################################
# Linking rules (one binary per .cc in src/apps or tests)
###############################################################################
# 1) Link each application independently
#    Example: (APP_DIR)/foo depends on object for foo + the "library" objects in src/.
$(APP_DIR)/%: $(OBJ_DIR)/src/apps/%.o $(OBJS)
	@mkdir -p $(@D)
	-$(CXXLINKER) -o $@ $^ $(PETSC_LIB)

# 2) Link each test binary
$(TEST_DIR)/%: $(OBJ_DIR)/tests/%.o $(OBJS)
	@mkdir -p $(@D)
	-$(CXXLINKER) -o $@ $^ $(PETSC_LIB) $(GTEST_LIB)

###############################################################################
# Automatically include dependency files
###############################################################################
-include $(DEPENDENCIES)

###############################################################################
# Cleaning
###############################################################################
clean::
	-@rm -rf $(OBJ_DIR)/* $(APP_DIR)/* $(TEST_DIR)/*

cleanall: clean
	-@rm -rf $(BUILD) $(HTML_DIR) $(LATEX_DIR)
