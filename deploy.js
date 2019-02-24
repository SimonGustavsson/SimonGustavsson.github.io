const { exec } = require('child_process');
const fs = require('fs');
const path = require('path');
const os = require('os');


fs.mkdtemp(path.join(os.tmpdir(), 'foo-'), (err, folder) => {
    if (err) throw err;

    const tempPath = folder + '\\' + 'main.min.js';

    fs.copyFile('main.min.js', tempPath, (err) => {
        if (err) throw err;

        console.log('Copied main.min.js to ' + tempPath);

        /*
        exec('git checkout foobar', (err, stdout, stderr) => {
            if (err) throw new Error(err);

            console.log(stdout);
        });
        */

        console.log('Deleting temp folder');

        fs.unlink(tempPath, err => {
            if (err) throw err;
            console.log('Removed ' + tempPath);

            fs.rmdir(folder, err => {
                if (err) throw err;

                console.log('Deleted ' + folder);
            });
        });
    });
});

