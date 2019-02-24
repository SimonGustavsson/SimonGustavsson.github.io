const { exec } = require('child_process');
const fs = require('fs');
const path = require('path');
const os = require('os');

function removeFileAndFolder(tempPath, folder) {
    fs.unlink(tempPath, err => {
        if (err) throw err;

        fs.rmdir(folder, err => {
            if (err) throw err;
        });
    });
}

fs.mkdtemp(path.join(os.tmpdir(), 'foo-'), (err, folder) => {
    if (err) throw err;

    const tempPath = folder + '\\' + 'main.min.js';

    fs.copyFile('main.min.js', tempPath, (err) => {
        if (err) throw err;

        exec('git checkout gh-pages', (err, stdout, stderr) => {
            if (err) throw new Error(err);

            fs.copyFile(tempPath, 'main.minCOPIED.js', err => {
                if (err) throw err;

                exec('git add -A && git commit -m "New deploy" && git checkout master', function (err2, stdout2, stderr2) {
                    if (err2) throw new Error(err2);

                    removeFileAndFolder(tempPath, folder);
                });
            });
        });
    });
});
