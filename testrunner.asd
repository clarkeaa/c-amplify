(asdf:defsystem :testrunner
    ;; System meta-data
    :name "compiler for c-amplify"
    :version "0.1"
    :maintainer "dep"
    :author "dep"
    :license "GPL"

    :depends-on (:compiler)

    ;; Components
    :serial t
    :components ((:file "tests/testrunner")))

