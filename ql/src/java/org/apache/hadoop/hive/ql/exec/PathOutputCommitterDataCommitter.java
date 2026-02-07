package org.apache.hadoop.hive.ql.exec;

import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.fs.PathFilter;
import org.apache.hadoop.hive.conf.HiveConf;
import org.apache.hadoop.hive.ql.metadata.Hive;
import org.apache.hadoop.hive.ql.metadata.HiveException;
import org.apache.hadoop.hive.ql.session.SessionState;
import org.apache.hadoop.mapreduce.JobContext;
import org.apache.hadoop.mapreduce.lib.output.PathOutputCommitter;

import java.io.IOException;
import java.util.List;

/**
 * A {@link DataCommitter} that commits Hive data using a {@link PathOutputCommitter}.
 */
class PathOutputCommitterDataCommitter implements DataCommitter {

  private final JobContext jobContext;
  private final PathOutputCommitter pathOutputCommitter;

  PathOutputCommitterDataCommitter(JobContext jobContext,
                                          PathOutputCommitter pathOutputCommitter) {
    this.jobContext = jobContext;
    this.pathOutputCommitter = pathOutputCommitter;
  }

  @Override
  public void moveFile(Path sourcePath, Path targetPath, boolean isDfsDir, HiveConf conf,
                       SessionState.LogHelper console) throws HiveException {
    commitJob();
  }

  @Override
  public void copyFiles(HiveConf conf, Path srcf, Path destf, FileSystem fs, boolean isSrcLocal,
                        boolean isAcidIUD, boolean isOverwrite, List<Path> newFiles,
                        boolean isBucketed, boolean isFullAcidTable,
                        boolean isManaged) throws HiveException {
    commitJob();
  }

  @Override
  public void replaceFiles(Path tablePath, Path srcf, Path destf, Path oldPath, HiveConf conf,
                           boolean isSrcLocal, boolean purge, List<Path> newFiles,
                           PathFilter deletePathFilter, boolean isNeedRecycle, boolean isManaged,
                           Hive hive) throws HiveException {
    commitJob();
  }

  private void commitJob() throws HiveException {
    try {
      this.pathOutputCommitter.commitJob(this.jobContext);
    } catch (IOException e) {
      throw new HiveException(e);
    }
  }
}
