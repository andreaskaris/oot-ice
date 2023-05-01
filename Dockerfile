FROM quay.io/centos/centos:stream8 as builder
WORKDIR /usr/src
RUN curl -L -O "https://downloadmirror.intel.com/772530/ice-1.11.14.tar.gz"
RUN yum install -y "@Development Tools" rpm-build kernel-headers kernel-devel
RUN rpmbuild -tb *.tar.gz
RUN find /usr/src

FROM quay.io/centos/centos:stream8
COPY --from=builder /usr/src/kernel-module-management/ci/kmm-kmod/kmm_ci_a.ko /opt/lib/modules/$4.18.0-372.40.1.el8_6.x86_64/
COPY --from=builder /usr/src/kernel-module-management/ci/kmm-kmod/kmm_ci_b.ko /opt/lib/modules/$4.18.0-372.40.1.el8_6.x86_64/
RUN depmod -b /opt 4.18.0-372.40.1.el8_6.x86_64
