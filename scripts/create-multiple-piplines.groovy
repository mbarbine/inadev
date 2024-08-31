def projects = [
    [name: "CI-Pipeline-1", repo: "https://github.com/your-repo/project-1.git"],
    [name: "CI-Pipeline-2", repo: "https://github.com/your-repo/project-2.git"],
    [name: "CI-Pipeline-3", repo: "https://github.com/your-repo/project-3.git"]
]

projects.each { project ->
    pipelineJob(project.name) {
        definition {
            cpsScm {
                scm {
                    git {
                        remote {
                            url(project.repo)
                            credentials('your-git-credentials-id')
                        }
                        branch('*/main')
                    }
                }
            }
        }
    }

    println "Pipeline ${project.name} has been created."
}
