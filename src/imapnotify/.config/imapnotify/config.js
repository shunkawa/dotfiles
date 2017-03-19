var child_process = require('child_process');

function getStdout(cmd) {
  var stdout = child_process.execSync(cmd);
  return stdout.toString().trim();
}

module.exports = {
  host: 'rkm.id.au',
  port: 993,
  tls: true,
  tlsOptions: { rejectUnauthorized: false },
  username: 'r@rkm.id.au',
  password: getStdout('pass ls auth-sources/r@rkm.id.au | head -n 1'),
  onNewMail: 'mbsync -a',
  onNewMailPost: 'notmuch new',
  boxes: [ 'INBOX' ],
};
