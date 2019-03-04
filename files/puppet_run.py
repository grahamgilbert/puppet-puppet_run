#!/usr/bin/python
# Puppet Wrapper to make sure it runs as expected

import subprocess
import logging
import logging.handlers
import os
import random
import time
import datetime
import argparse
import sys
import plistlib
import ConfigParser

run_lock_file = '/opt/puppetlabs/puppet/cache/state/agent_catalog_run.lock'
disabled_lock_file = '/opt/puppetlabs/puppet/cache/state/agent_disabled.lock'
max_delay = 1500
lastrun_file = '/opt/puppetlabs/puppet/cache/state/lastrun.plist'

# stolen from munki below


def log(msg):
    """Generic logging function."""
    if len(msg) > 1000:
        # See http://bugs.python.org/issue11907 and RFC-3164
        # break up huge msg into chunks and send 1000 characters at a time
        msg_buffer = msg
        while msg_buffer:
            logging.info(msg_buffer[:1000])
            msg_buffer = msg_buffer[1000:]
    else:
        logging.info(msg)  # noop unless configure_syslog() is called first.


def configure_syslog():
    """Configures logging to system.log, when pref('LogToSyslog') == True."""
    logger = logging.getLogger()
    # Remove existing handlers to avoid sending unexpected messages.
    for handler in logger.handlers:
        logger.removeHandler(handler)
    logger.setLevel(logging.DEBUG)

    # If /System/Library/LaunchDaemons/com.apple.syslogd.plist is restarted
    # then /var/run/syslog stops listening.  If we fail to catch this then
    # Munki completely errors.
    try:
        syslog = logging.handlers.SysLogHandler('/var/run/syslog')
    except:
        log('LogToSyslog is enabled but socket connection failed.')
        return

    syslog.setFormatter(logging.Formatter('puppetrun: %(message)s'))
    syslog.setLevel(logging.INFO)
    logger.addHandler(syslog)

    # just for you, this bit is not in munki.
    stdout_logging = logging.StreamHandler()
    stdout_logging.setFormatter(logging.Formatter())
    logging.getLogger().addHandler(stdout_logging)

# stolen from munki above


def random_delay():
    randomized_delay = random.randrange(0, max_delay)
    print "Delaying run by %s seconds" % randomized_delay
    log("Delaying run by %s seconds" % randomized_delay)
    time.sleep(randomized_delay)


def preflight():
    # ToDo
    # * Make sure puppet.conf exists, if not, place it
    # * look for vardir, create if it does not exist
    # * look for /etc/puppet, create if it does not exist
    log("Running Puppet Preflight Actions...")

    if os.path.exists(run_lock_file):
        log(
            "Agent Run Lock file is present, cleaning up previous run...")
        old_pid = read_pidfile(run_lock_file)
        os.remove(run_lock_file)
        if check_for_process(old_pid):
            os.kill(int(old_pid), 9)

    if os.path.exists(disabled_lock_file):
        log(
            "Agent Disabled Lock file is present, cleaning up previous run...")
        old_pid = read_pidfile(disabled_lock_file)
        os.remove(disabled_lock_file)
        if check_for_process(old_pid):
            os.kill(int(old_pid), 9)


def read_pidfile(pidfile):
    if os.path.exists(pidfile):
        with file(pidfile) as f:
            pid = f.read()
            f.close()
        result = pid.rstrip('\n')
    else:
        result = False

    return result


def check_for_process(pid):
    cmd = ['/bin/ps', '-p', pid, '-o', 'pid=']
    proc = subprocess.Popen(
        cmd,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE)
    (output, _) = proc.communicate()
    # debugging
    # print("check_for_process output = %s" % output)
    return output.rstrip('\n')


def run_puppet(environment=None):
    # ToDo
    # * Run puppet and capture output.
    # * Check for cert errors:
    #   'Retrieved certificate does not match private key')
    #   'Certificate request does not match existing certificate')
    # * If cert errors exist, clean up ssl dir and email about it?

    returncode = 1
    puppet_cmd = [
        '/opt/puppetlabs/bin/puppet',
        'agent',
        '--test',
        '--color',
        'false']

    log("Running Puppet...")

    if environment:
        puppet_cmd += ['--environment', environment]

    proc = subprocess.Popen(
        puppet_cmd,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT)

    for line in iter(proc.stdout.readline, ''):
        log(str(line).rstrip())

    returncode = proc.wait()
    if returncode == 0 or returncode == 2:
        return int(time.time())
    else:
        return False


def update_lastrun_file(run_status):
    if run_status == False:
        if os.path.exists(lastrun_file):
            lastrun_data = plistlib.readPlist(lastrun_file)
            try:
                run_status = lastrun_data['LastSuccess']
            except:
                run_status = 0
        else:
            run_status = 0
    if run_status == 0:
        status = False
    else:
        status = True

    data = dict(
            status = status,
            LastSuccess = run_status,
            lastrun=datetime.datetime.fromtimestamp(
                time.mktime(
                    time.gmtime())))
    plistlib.writePlist(data, lastrun_file)
    return data

def cleanup_environment_on_error(last_run_data):
    """
    If the last success was more than 24 hours ago, remove any configured
    environment (just in case).
    """
    now = int(time.time())
    day_ago = now - 86400
    if last_run_data['LastSuccess'] < day_ago:
        config = ConfigParser.RawConfigParser()
        config.read(r'/etc/puppetlabs/puppet/puppet.conf')
        if config.has_section('agent'):
            if 'environment' in config.options('agent'):
                config.remove_option('agent','environment')
                print config.options('agent')
                with open(r'/etc/puppetlabs/puppet/puppet.conf', 'wb') as configfile:
                    config.write(configfile)

def main():
    if os.geteuid() != 0:
        print >> sys.stderr, 'You must run this as root!'
        sys.exit(1)
    os.environ["LANG"] = "en_US.UTF-8"
    parser = argparse.ArgumentParser()
    parser.add_argument(
        '--now',
        action='store_true',
        help='Run script immediately')
    parser.add_argument(
        '--environment',
        help='Run with a specific environment'
    )
    args = parser.parse_args()
    configure_syslog()
    if not args.now:
        random_delay()
    if args.environment:
        environment = args.environment
    else:
        environment = None
    preflight()
    run_status = run_puppet(environment)
    last_run_data = update_lastrun_file(run_status)
    cleanup_environment_on_error(last_run_data)


if __name__ == "__main__":
    main()
