# define check_requirement
#   $(eval RAW := $1)
#   $(eval TECH := $(shell echo $(RAW) | sed -E 's/([^@]+)@\[.*/\1/'))
#   $(eval MIN_VER := $(shell echo $(RAW) | sed -E 's/[^@]+@\[(.*),.*/\1/'))
#   $(eval CMD := $(shell echo $(RAW) | sed -E 's/[^@]+@\[[^,]+, *(.*)\]/\1/'))
# 	@echo $(RAW)
# 	@echo $(TECH)
# 	@echo $(MIN_VER)
# 	@echo $(CMD)

#   @if ! command -v $(TECH) >/dev/null 2>&1; then \
#     echo "[✗] $(TECH) not installed (required >= $(MIN_VER))"; \
#   else \
#     INSTALLED_VER_RAW=$$($(CMD) | grep -Eo '[0-9]+(\.[0-9]+)+' | head -n1); \
# 		echo "INSTALLED_VER_RAW: $(INSTALLED_VER_RAW)" \
#     CLEAN_INSTALLED_VER=$$(echo $$INSTALLED_VER_RAW | tr -cd '0-9.'); \
#     CLEAN_MIN_VER=$$(echo $(MIN_VER) | tr -cd '0-9.'); \
#     INSTALLED_VER_NUM=$$(echo $$CLEAN_INSTALLED_VER | awk -F. '{ printf "%d%02d%02d\n", $$1, $$2, $$3 }'); \
#     MIN_VER_NUM=$$(echo $$CLEAN_MIN_VER | awk -F. '{ printf "%d%02d%02d\n", $$1, $$2, $$3 }'); \
#     if [ $$INSTALLED_VER_NUM -lt $$MIN_VER_NUM ]; then \
#       echo "[✗] $(TECH) version $$CLEAN_INSTALLED_VER is too old (required >= $(MIN_VER))"; \
#     else \
#       echo "[✓] $(TECH) version $$CLEAN_INSTALLED_VER OK (>= $(MIN_VER))"; \
#     fi; \
#   fi
# endef

define check_requirement
  RAW="$1"; \
  TECH=$$(echo $$RAW | sed -E 's/([^@]+)@\[.*/\1/'); \
  MIN_VER=$$(echo $$RAW | sed -E 's/[^@]+@\[([^,]+),.*/\1/'); \
  CMD=$$(echo $$RAW | sed -E 's/[^@]+@\[[^,]+, *(.*)\]/\1/'); \
  if ! command -v $$TECH >/dev/null 2>&1; then \
    echo "[✗] $$TECH not installed (required >= $$MIN_VER)"; \
  else \
    INSTALLED_VER_RAW=$$($$CMD | grep -Eo '[0-9]+(\.[0-9]+)+' | head -n1); \
    CLEAN_VER=$$(echo $$INSTALLED_VER_RAW | tr -cd '0-9.'); \
    CLEAN_MIN=$$(echo $$MIN_VER | tr -cd '0-9.'); \
    VER_NUM=$$(echo $$CLEAN_VER | awk -F. '{ printf "%d%02d%02d\n", $$1, $$2, $$3 }'); \
    MIN_NUM=$$(echo $$CLEAN_MIN | awk -F. '{ printf "%d%02d%02d\n", $$1, $$2, $$3 }'); \
    if [ $$VER_NUM -lt $$MIN_NUM ]; then \
      echo "[✗] $$TECH version $$CLEAN_VER is too old (required >= $$MIN_VER)"; \
    else \
      echo "[✓] $$TECH version $$CLEAN_VER OK (>= $$MIN_VER)"; \
    fi; \
  fi
endef