(asdf:defsystem :compiler
    ;; System meta-data
    :name "compiler for c-amplify"
    :version "0.1"
    :maintainer "dep"
    :author "dep"
    :license "GPL"

    :depends-on (:c-amplify :unix-options)

    ;; Components
    :serial t
    :components ((:file "compiler")))

