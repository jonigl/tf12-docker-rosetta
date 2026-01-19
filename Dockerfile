FROM hashicorp/terraform:0.12.31

# Install AWS CLI, Git, and OpenSSH client (needed for SSH git operations)
RUN apk add --no-cache python3 py3-pip git openssh-client bash && \
    pip3 install awscli

# Create symlinks in /usr/local/bin where terraform looks for executables
RUN ln -sf /usr/bin/git /usr/local/bin/git && \
    ln -sf /usr/bin/ssh /usr/local/bin/ssh

# Ensure PATH includes all standard binary locations
ENV PATH="/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/sbin:/bin:$PATH"

WORKDIR /workspace

# Create a wrapper script that ensures environment is set up correctly
RUN echo '#!/bin/sh' > /usr/local/bin/terraform-wrapper && \
    echo 'export PATH="/usr/local/bin:/usr/bin:/bin:$PATH"' >> /usr/local/bin/terraform-wrapper && \
    echo 'exec /bin/terraform "$@"' >> /usr/local/bin/terraform-wrapper && \
    chmod +x /usr/local/bin/terraform-wrapper

ENTRYPOINT ["/usr/local/bin/terraform-wrapper"]
