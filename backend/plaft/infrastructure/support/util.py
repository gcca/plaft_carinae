"""
.. module:: plaft.infrastructure.support
   :synopsis: Utils: encryption, hash, identifiers, json, encoders, etc.

.. moduleauthor:: Gonzales Castillo, Cristhian A. <cristhian.gz@aol.com>

Attributes:
  CHOICES (str): Characters to generate random strings.
  SECRET (str): Internal secret string to ecnrypt.


"""

import random
import hmac
import bcrypt
from string import digits, letters


CHOICES = digits + '!"#$%&\\(;.:)=?+-*/' + letters
SECRET = 'J:u(8"(v/i#:g)3-u3E&"'


# user stuff

def make_pw_hash(name, password, salt=None):
    """Make password hash.

    Args:
      name (str): Password complement.
      password (str): The password.
      salt (str): Random characters which are added to the password.

    Returns:
      str: Password hash.

    Raises:
      ValueError, TypeError: Bad parameters.

    """
    if not salt:
        salt = bcrypt.gensalt(2)

    try:
        hashed = bcrypt.hashpw(name + password, salt)
    except (ValueError, TypeError):
        pass
    else:
        return hashed


def valid_pw(name, password, hashed):
    """Valid password.

    Args:
      name (str): Password complement.
      password (str): The password.
      hashed (str): Hashed user password.

    Returns:
      bool: True when user string match with hashed string.

    Raises:
      ValueError: Bad parameters.

    """
    return hashed == make_pw_hash(name, password, hashed)


def make_salt(length=9):
    """Make salt by length.

    Args:
      length (int): Salt length.

    Returns:
      str: Salt.

    """
    return ''.join(random.choice(CHOICES) for _ in xrange(length))


def make_secure(val, salt=None):
    """Make secure value.

    Args:
      val (str): Non-secure value.
      salt (str): The Salt.

    Returns:
      str: Secured value.

    """
    if not salt:
        salt = make_salt()
    return '%s|%s|%s' % (val, salt, hmac.new(SECRET, val+salt).hexdigest())


def check_secure(secure_val):
    """Check secure value.

    Args:
      secure_val (str): Secured value.

    Returns:
      str: ``value`` if corrected secure value. None otherwise.

    Raises:
      ValueError: Error spliting ``secure_val``.

    """
    try:
        val, salt, _ = secure_val.split('|')
    except ValueError:
        pass
    else:
        return val if secure_val == make_secure(val, salt) else None


# vim: et:ts=4:sw=4
