const { exec } = require('child_process');
const fs = require('fs').promises;
const path = require('path');
const os = require('os');

(async function () {
    try {
        const tempFolder = await fs.mkdtemp(path.join(os.tmpdir(), 'foo-'));

        const tempJS = path.join(tempFolder, 'build\\main.min.js');
        const tempHTML = path.join(tempFolder, 'index.html');

        await fs.copyFile('build\\main.min.js', tempJS);
        await fs.copyFile('index.html', tempHTML);
        await execAsync('git checkout gh-pages');

        await fs.copyFile(tempJS, 'main.min.js');
        await fs.copyFile(tempHTML, 'index.html');

        await execAsync('git add -A && git commit -m "New deploy" && git checkout master');

        await fs.unlink(tempJS);
        await fs.unlink(tempHTML);
        await fs.rmdir(tempFolder);
    } catch (err) {
        console.error(`Deploy failed : ${err.message}`);
    }
})();

async function execAsync(command) {
    return new Promise(function (resolve, reject) {
        exec(command, (err, stdout, stderr) => {
            if (err) {
                reject(err);
            } else {
                resolve(stdout);
            }
        });
    });
}

/*

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

*/